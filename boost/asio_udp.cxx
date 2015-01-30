#include <iostream>
#include <sstream>
#include <boost/asio.hpp>
#include <boost/lexical_cast.hpp>
#include <boost/thread.hpp>
#include <boost/bind.hpp>
#include <boost/optional.hpp>

class udp_reciever
{
public:
  udp_reciever(boost::asio::io_service& io, int p)
  : Port(p),
    Socket(io, boost::asio::ip::udp::endpoint(boost::asio::ip::udp::v4(), p))
  {
    std::cout << "Creating udp socket on " << this->Port << std::endl;
    this->StartReciever();
  }
  ~udp_reciever()
  {
    std::cout << "Killing udp socket on " << this->Port << std::endl;
    this->Socket.cancel();
  }

private:
  void StartReciever()
  {
    this->Socket.async_receive_from(
      boost::asio::buffer(this->Buf, 256), this->Remote,
      boost::bind(&udp_reciever::Reciever, this,
        boost::asio::placeholders::error,
        boost::asio::placeholders::bytes_transferred));
  }

  void Reciever(const boost::system::error_code& error, std::size_t n)
  {
    if(error)
      {
      //std::cout << " Error code: " << error << std::endl;
      return;
      }

    std::string msg(this->Buf, n);
    std::cout << "Port" << this->Port << ": " << msg << std::endl;
    this->StartReciever();
  }

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
  boost::asio::io_service::work *w = new boost::asio::io_service::work(io);

  // This thread will stay active until we clear the dummy work
  // regardless of the lifetime of sockets coming and going
  std::cout << "Launching run thread..." << std::endl;
  boost::thread t(boost::bind(&boost::asio::io_service::run, &io));

  {
    udp_reciever u1(io, p1);
    udp_reciever u2(io, p2);
    std::string input;
    while(input != "q")
    {
    std::getline(std::cin, input);
    }
  }

  // io_service is still alive so let's start some more sockets
  {
    udp_reciever u1(io, p1+100);
    udp_reciever u2(io, p2+100);
    std::string input;
    while(input != "q")
    {
    std::getline(std::cin, input);
    }
  }

  std::cout << "Deleting the dummy work to shutdown..." << std::endl;
  delete w;

  std::cout << "Waiting for IO service to exit..." << std::endl;
  t.join();
  

  return 0;
}
