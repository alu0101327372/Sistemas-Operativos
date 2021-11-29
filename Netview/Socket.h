// Universidad de La Laguna
// Escuela Superior de Ingeniería y Tecnología
// Grado en Ingeniería Informática
// Asignatura: Sistemas Operativos // Curso: 2º
// Práctica de programación: NetView
// Autor: Marco Antonio Cabrera Hernández
// Correo: alu0101327372@ull.es
// Fecha: 20/11/2021
// Archivo Socket.h:
//      Contiene la definición de la clase Socket.
// Revisión histórica
//      29/11/2021 - Creación (primera versión) del código
#include "File.h"

#include <iostream>
#include <array>
#include <string>

#include <sys/types.h>
#include <sys/stat.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#include <cerrno>
#include <cstring>
#include <stdexcept>
#include <system_error>

struct Message {
  std::array<char, 1024> text;
};

class Socket {
  public:
  Socket(const std::string& ip_address, int port);
  ~Socket(void);

  void send_to(const Message& message, const sockaddr_in& address);
  void receive_from(Message& message, sockaddr_in& address);

  private:
  void build(const sockaddr_in& address);
  void destroy(void);
  int fd_;
};

sockaddr_in make_ip_address(int port, const std::string& ip_address = std::string());