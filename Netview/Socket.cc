// Universidad de La Laguna
// Escuela Superior de Ingeniería y Tecnología
// Grado en Ingeniería Informática
// Asignatura: Sistemas Operativos // Curso: 2º
// Práctica de programación: NetView
// Autor: Marco Antonio Cabrera Hernández
// Correo: alu0101327372@ull.es
// Fecha: 20/11/2021
// Archivo Socket.h:
//      Contiene la implementación de la clase Socket.
// Revisión histórica
//      29/11/2021 - Creación (primera versión) del código
#include "Socket.h"

void Socket::build(const sockaddr_in& address) {
  // Creamos el socket
  fd_ = socket(AF_INET, SOCK_DGRAM, 0);
  if (fd_ < 0) {
    throw std::system_error(errno, std::system_category(), "No se pudo crear el socket");
  }
  // Asignamos una direccion al socket
  int bind_result = bind(fd_, reinterpret_cast<const sockaddr*>(&address), sizeof(address));
  if (bind_result < 0) {
    throw std::system_error(errno, std::system_category(), "Falló la asignación de dirección al socket");
  }
}



void Socket::destroy(void) {
  int result = close(fd_);
  if (result < 0) {
    throw std::system_error(errno, std::system_category(), "No se pudo cerrar el archivo"); 
  }
}



Socket::Socket(const std::string& ip_address, int port) {
  sockaddr_in address {make_ip_address(port, ip_address)};
  build(address);
}



Socket::~Socket(void) {
  destroy();
}



void Socket::send_to(const Message& message, const sockaddr_in& address) {
  int result = sendto(fd_, &message, sizeof(message), 0, reinterpret_cast<const sockaddr*>(&address),sizeof(address));
  if (result < 0) {
    throw std::system_error(errno, std::system_category(), "Falló el envío");
  }
}



void Socket::receive_from(Message& message, sockaddr_in& address) {
  socklen_t src_len = sizeof(address);

  int result = recvfrom(fd_, &message, sizeof(message), 0, reinterpret_cast<sockaddr*>(&address), &src_len);
  if (result < 0) {
    throw std::system_error(errno, std::system_category(), "Falló la recepción: ");
  }
  // Convertimos la dirección IP como entero de 32 bits en una cadena de texto.
  char* remote_ip = inet_ntoa(address.sin_addr);
  // Recuperamos el puerto del remitente en el orden adecuado para nuestra CPU
  int remote_port = ntohs(address.sin_port);
  message.text[1023] = '\0';
}



sockaddr_in make_ip_address(int port, const std::string& ip_address_input) {
  if ((port < 1) || (65535  < port)) {
    throw std::system_error(errno, std::system_category(), "Puerto no válido");
  }
  sockaddr_in result_address{};
  result_address.sin_family = AF_INET;

  if (ip_address_input == "") {
    result_address.sin_addr.s_addr = htonl(INADDR_ANY);
  } else {
    int ip_string_length = ip_address_input.length();
    char ip_address_char [ip_string_length + 1];
    // Pasamos la direccion ip de string a char[]
    strcpy(ip_address_char, ip_address_input.c_str());

    in_addr ip_address;
    // Convertimos la cadena de input en enteros de 32 bits
    int error = inet_aton(ip_address_char, &ip_address);

    if (error == 0) {
      throw std::system_error(errno, std::system_category(), "Direccion ip no valida");
    }
    result_address.sin_addr.s_addr = ip_address.s_addr;
  }
  result_address.sin_port = htons(port);
  return result_address;
}