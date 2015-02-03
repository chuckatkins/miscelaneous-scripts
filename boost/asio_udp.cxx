#include <iostream>
#include <sstream>
#include <boost/asio.hpp>
#include <boost/lexical_cast.hpp>
#include <boost/thread.hpp>
#include <boost/bind.hpp>
#include <boost/smart_ptr.hpp>

class udp_receiver
{
public:
  udp_receiver(boost::asio::io_service& io, int p)
  : IsReceiving(false), ShouldStop(false), Port(p),
    Socket(io, boost::asio::ip::udp::endpoint(boost::asio::ip::udp::v4(), p))
  {
    std::cout << "Port[" << this->Port << "] Ctor : "
              << "Creating udp socket" << std::endl;
    this->StartReceiver();
  }

  ~udp_receiver()
  {
    // This aborts any currently pending async operations
    std::cout << "Port[" << this->Port << "] Dtor : "
              << "Aborting receiver" << std::endl;
    this->Socket.cancel();

    std::cout << "Port[" << this->Port << "] Dtor : "
              << "Waiting for receiver to stop" << std::endl;
      {
      boost::unique_lock<boost::mutex> guard(this->IsReceivingMtx);
      this->ShouldStop = true;
      while(this->IsReceiving)
        {
        this->IsReceivingCond.wait(guard);
        }
      }

    std::cout << "Port[" << this->Port << "] Dtor : "
              << "Deleting" << std::endl;
  }

private:
  void StartReceiver()
  {
    std::cout << "Port[" << this->Port << "] Strt : "
              << "(Re)Starting receiver" << std::endl;

      {
      boost::lock_guard<boost::mutex> guard(this->IsReceivingMtx);
      this->IsReceiving = true;
      }

    this->Socket.async_receive_from(
      boost::asio::buffer(this->Buf, 256), this->Remote,
      boost::bind(&udp_receiver::Receiver, this,
        boost::asio::placeholders::error,
        boost::asio::placeholders::bytes_transferred));
  }

  void Receiver(const boost::system::error_code& error, std::size_t n)
  {
    // This will error out when cancel is called but I suppose other error
    // conditions could occur.  Probably best to check for specific error
    // codes and handle each accordingly.
    if(error || this->ShouldStop)
      {
      //std::cout << " Error code: " << error << std::endl;
      std::cout << "Port[" << this->Port << "] Recv : "
                << "Stopping receiver" << std::endl;

        {
        boost::lock_guard<boost::mutex> guard(this->IsReceivingMtx);
        this->IsReceiving = false;
        }
      this->IsReceivingCond.notify_one();

      return;
      }

    // Just dump the data to stdout. Insert your own logic here.
    std::string msg(this->Buf, n);
    std::cout << "Port[" << this->Port << "] Recv : "
              << msg.size() << " bytes received" << std::endl;

    // Keep it alive
    this->StartReceiver();
  }

  bool IsReceiving;
  bool ShouldStop;
  boost::mutex IsReceivingMtx;
  boost::condition_variable IsReceivingCond;

  int Port;
  char Buf[256];
  boost::asio::ip::udp::socket Socket;
  boost::asio::ip::udp::endpoint Remote;
};


int main(int argc, char **argv)
{
  if(argc != 3)
    {
    std::cerr << "Usage: " << argv[0] << " [port1] [port2]" << std::endl;
    return 1;
    }

  int p1, p2;
  try
    {
    p1 = boost::lexical_cast<int>(argv[1]);
    p2 = boost::lexical_cast<int>(argv[2]);
    }
  catch(const boost::bad_lexical_cast& e)
    {
    std::cerr << "Error: Unable to parse ports: " << e.what() << std::endl;
    return 2;
    }

  std::cout << "Creating io_service..." << std::endl;
  boost::asio::io_service io;

  std::cout << "Creating dummy work for the io_service..." << std::endl;
  boost::scoped_ptr<boost::asio::io_service::work> w(
    new boost::asio::io_service::work(io));

  // This thread will stay active until we clear the dummy work
  // regardless of the lifetime of sockets coming and going
  std::cout << "Launching run thread..." << std::endl;
  boost::thread t(boost::bind(&boost::asio::io_service::run, &io));

  boost::scoped_ptr<udp_receiver> u1(new udp_receiver(io, p1));
  boost::scoped_ptr<udp_receiver> u2(new udp_receiver(io, p2));

  std::cout << "Type q to stop the sockets" << std::endl;
  std::string input;
  while(input != "q")
    {
    std::getline(std::cin, input);
    }

  std::cout << "DELETE" << std::endl;
  u1.reset();
  u2.reset();
  
  std::cout << "Deleting the dummy work to shutdown..." << std::endl;
  w.reset();

  std::cout << "Waiting for IO service to exit..." << std::endl;
  t.join();
  
  return 0;
}
