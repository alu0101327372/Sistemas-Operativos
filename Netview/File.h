// Universidad de La Laguna
// Escuela Superior de Ingeniería y Tecnología
// Grado en Ingeniería Informática
// Asignatura: Sistemas Operativos // Curso: 2º
// Práctica de programación: NetView
// Autor: Marco Antonio Cabrera Hernández
// Correo: alu0101327372@ull.es
// Fecha: 20/11/2021
// Archivo Socket.h:
//      Contiene la programa definición de la clase File.
// Revisión histórica
//      29/11/2021 - Creación (primera versión) del código
#include <fcntl.h>
#include <unistd.h>

#include <iostream>

class File {
  public:
  File(const char* pathname, int flags);
  ~File(void) noexcept(false);

  ssize_t read_from_file(void* buf, size_t count);
  ssize_t write_to_file(void* buf, size_t count);
  private:
    int fd_;
};