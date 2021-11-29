// Universidad de La Laguna
// Escuela Superior de Ingeniería y Tecnología
// Grado en Ingeniería Informática
// Asignatura: Sistemas Operativos // Curso: 2º
// Práctica de programación: NetView
// Autor: Marco Antonio Cabrera Hernández
// Correo: alu0101327372@ull.es
// Fecha: 20/11/2021
// Archivo Socket.h:
//      Contiene la programa principal de la recepción de datos.
// Revisión histórica
//      29/11/2021 - Creación (primera versión) del código
#include "Socket.h"

int protected_main() {
  Socket socket_receive("127.0.0.1", 1024);
  Message message;
  sockaddr_in address{make_ip_address(1024, "192.168.1.35")};
  while (1 == 1) {
    socket_receive.receive_from(message, address);
  }
  return 0;
}

int main() {
  try {
    return protected_main();
  }    
  catch(std::bad_alloc& e) {
    std::cerr << "mytalk" << ": memoria insuficiente\n";
    return 1;
  }
  catch(std::system_error& e) {
    std::cerr << "mitalk" << ": " << e.what() << '\n';
    return 2;
  }
  catch (...) {
    std::cout << "Error desconocido\n";
    return 99;
  }
}
