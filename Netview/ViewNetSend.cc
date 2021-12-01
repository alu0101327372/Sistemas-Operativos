// Universidad de La Laguna
// Escuela Superior de Ingeniería y Tecnología
// Grado en Ingeniería Informática
// Asignatura: Sistemas Operativos // Curso: 2º
// Práctica de programación: NetView
// Autor: Marco Antonio Cabrera Hernández
// Correo: alu0101327372@ull.es
// Fecha: 20/11/2021
// Archivo Socket.h:
//      Contiene la programa principal del envío de datos.
// Revisión histórica
//      29/11/2021 - Creación (primera versión) del código
#include "Socket.h"

int protected_main() {
  Socket socket_send("127.0.0.1", 3000);
  char* filename = "prueba.txt";
  File file_send(filename, O_RDONLY);

  Message message;
  size_t count = 1023;
  sockaddr_in address{make_ip_address(1024, "127.0.0.1")};
  while (file_send.read_from_file(&message.text, count) != 0 ) {
    message.text[1023] = '\0';
    socket_send.send_to(message,address);
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
