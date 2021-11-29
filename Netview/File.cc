// Universidad de La Laguna
// Escuela Superior de Ingeniería y Tecnología
// Grado en Ingeniería Informática
// Asignatura: Sistemas Operativos // Curso: 2º
// Práctica de programación: NetView
// Autor: Marco Antonio Cabrera Hernández
// Correo: alu0101327372@ull.es
// Fecha: 20/11/2021
// Archivo Socket.h:
//      Contiene la programa implementación de la clase File.
// Revisión histórica
//      29/11/2021 - Creación (primera versión) del código
#include "File.h"

File::File(const char* pathname, int flags) {
  fd_ = open(pathname, flags);
  if (fd_ < 0) {
    throw std::system_error(errno, std::system_category(), "No se pudo abrir el archivo"); 
  }
}



File::~File() {
  int result = close(fd_);
  if (result < 0) {
    throw std::system_error(errno, std::system_category(), "No se pudo cerrar el archivo"); 
  }
}



ssize_t File::read_from_file(void* buf, size_t count) {
  return read(fd_, buf, count);
}



ssize_t File::write_to_file(void* buf, size_t count) {
  return write(fd_, buf, count);
}