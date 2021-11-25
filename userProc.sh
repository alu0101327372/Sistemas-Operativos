#!/bin/bash
# Universida de La Laguna
# Sistemas Operativos - Procesos de Usuarios en Bash
# Autor: Marco Antonio Cabrera Hernández
# e-mail: alu0101327372@ull.edu.es

# Estilos
TEXT_BOLD=$(tput bold)
TEXT_GREEN=$(tput setaf 2)
TEXT_YELLOW=$(tput setaf 3)
TEXT_RED=$(tput setaf 9)
TEXT_RESET=$(tput sgr0)

# Constantes
TEMPFILE=$(mktemp)
OUTFILE=$(mktemp)

# Variables
users=
users_who=
users_time=
tmp_user=
args=
filter=
number_of_users=0
op_t=0
op_u=0
op_usr=0
op_inv=0
op_pid=0
op_c=0
op_count=0
time_cpu=1

# Funcion para ver cual es el pid del proceso mas antiguo de un usuario
user_oldest_process_pid() {
	# Si el usuario no tiene procesos en marcha lo indicamos en lugar de no poner nada
	if [ "$(ps --no-headers -u $1 -o pid --sort=-etime| tr -d ' ' | head -1)" = "" ]; then
		echo $TEXT_GREEN"User currently has no processes running"$TEXT_RESET
	else
		ps --no-headers -u $1 -o pid --sort=-etime| tr -d ' ' | head -1
	fi
}



# Funcion para ver el numero total de procesos de un usuario
user_total_process() {
  ps -u $1 | wc -l
}



# Funcion para encontrar el tiempo total del proceso con mas tiempo consumido
user_lastest_process() {
  ps -u $1 -oetimes --sort=etimes | tail -n 1
}



# Funcion para encontrar el UID del usuario
uid() {
  id -u $1
}



# Funcion para encontrar el GID del usuario
gid() {
  id -g $1
}



# Función usuarios con procesos con un tiempo mayor a n
userProc() {
  ps --no-headers -u $1 -ocputimes,user | awk -v tiempo=$time_cpu '{if ($1 > tiempo) print $2}' | sed 's/^[[:space:]]*//' | sort | uniq
}



# Función para contar el numero de procesos total con un tiempo mayor a n 
userProcCount() {
  ps --no-headers -u $1 -ocputimes | awk -v tiempo=$time_cpu '{if ($1 > tiempo) print $1}' | sed 's/^[[:space:]]*//' | sort | uniq | wc -l
}



# Funcion de uso
usage() {
	echo "usage: $basename [-t time] [-usr] [-u user] [-count] [-inv] [-pid] [-c]"
}



# Funcion para salir en caso de error.
error_exit() {
	echo $TEXT_RED"$1"$TEXT_RESET 1>&2
	exit 1
}



# Comprobamos el comando que precede al -inv
args=($@)
length="${#args[@]}"
for (( i=0; i<length; i++ )); do
  for j in "${args[@]}"; do
    if [ "$j" = "-inv" ]; then
      index=$(( $i-1 ))
    fi
  done
done
# Guarda la opcion que es anterior a -inv, pues esa será la opcion a invertir
filter=${args[index]}

# Programa principal
while [ "$1" != "" ]; do
  case $1 in
    -h | --help )
      usage 
      exit 1
    ;;
    
    -t )
      shift
      # El argumento -t n, si n no es numero muestra error
      if [ "$1" != "" ]; then
        if [[ ! -n ${1//[0-9]/} ]]; then
          op_t=1
          time_cpu=$1
        else
          error_exit "Input is not a number"
        fi
      else
        error_exit "Input is not a number"
      fi
    ;;

    -usr )
      op_usr=1
    ;;

    -u )
      shift
      op_u=1
      while [ "$1" != "" ]; do
        # Comprobamos cual es el primer caracter de $1, si es un "-", es cualquier otra opcion
        if [ $(echo $1 | head -c 1) = "-" ]; then
          if [ "$1" = "-count" ]; then
            op_count=1
          elif [ "$1" = "-inv" ]; then
            op_inv=1
          elif [ "$1" = "-c" ]; then
            op_c=1
          elif [ "$1" = "-usr" ]; then
            op_usr=1
          elif [ "$1" = "-pid" ]; then
            op_pid=1
          elif [ "$1" = "-t" ]; then
            shift
            time_cpu=$1
          else
            error_exit "Option not supported"
          fi
          break
        else
          # Comprobamos si el usuario existe
          if id "$1" &>/dev/null; then
            # Añadimos a $1 los usuarios que siguen despues de -u ...
            users="$users $1"
            number_of_users=$(( $number_of_users + 1 ))
          else
            echo $TEXT_RED"The user $1 does not exist"$TEXT_RESET 1>&2
          fi
          shift
        fi
      done
    ;;

    -count )
      op_count=1
    ;;

    -inv )
      op_inv=1
    ;;

    -pid )
      op_pid=1
    ;;

    -c )
      op_c=1
    ;;

    * )
      error_exit "Error: option not supported" 
  esac
  shift
done

# Imprime el cabecero de la salida por pantalla
printf "\e[1;34m%s %s %s %s %s %s\n\e[0m" USER UID GID TP OPID LP >> ${OUTFILE}

# Si se utiliza la opcion -usr los usuarios que utilizamos son los del who
if [[ "$op_usr" = 1 ]] && [[ "$op_u" != 1 ]]; then
  users=$(who | cut -d " " -f 1 | sort | uniq)
  if [ "$users" = "" ]; then
    error_exit "There are no users"
  fi
  # Itera sobre los usarios del who que cumplen la condicion de tiempo y guarda el resultado en un archivo temporal
  for user in $users; do
    for i in $(userProc $user); do
      if [ "$op_count" = 1 ]; then
        printf "%s %d %d %d %d %d\n" $i $(uid $i) $(gid $i) $(userProcCount $i) $(user_oldest_process_pid $i) $(user_lastest_process $i) >> ${TEMPFILE}
      else
        printf "%s %d %d %d %d %d\n" $i $(uid $i) $(gid $i) $(user_total_process $i) $(user_oldest_process_pid $i) $(user_lastest_process $i) >> ${TEMPFILE}
      fi
    done
  done
elif [ "$op_u" = 1 ] && [[ "$op_usr" != 1 ]]; then
  if [ "$users" = "" ]; then
    error_exit "There are no users"
  fi
# Itera sobre los usarios de la opcion -u que cumplen la condicion de tiempo y guarda el resultado en un archivo temporal
  for (( i=1; i<=number_of_users; i++ )); do
    tmp_user=$(echo $users | cut -d " " -f $i)
    for j in $(userProc $tmp_user); do
      if [ "$op_count" = 1 ]; then
        printf "%s %d %d %d %d %d\n" $j $(uid $j) $(gid $j) $(userProcCount $j) $(user_oldest_process_pid $j) $(user_lastest_process $j) >> ${TEMPFILE}
      else
        printf "%s %d %d %d %d %d\n" $j $(uid $j) $(gid $j) $(user_total_process $j) $(user_oldest_process_pid $j) $(user_lastest_process $j) >> ${TEMPFILE}
      fi
    done
  done
elif [ "$op_u" = 1 ] && [[ "$op_usr" = 1 ]]; then
  users_who=$(who | cut -d " " -f 1 | sort | uniq)
  if [ "$users" = "" ]; then
    error_exit "There are no users"
  fi
  for user in $users_who; do 
    for (( i=1; i<=number_of_users; i++ )); do 
      tmp_user=$(echo $users | cut -d " " -f $i)
      if [ "$user" = "$tmp_user" ]; then
        for j in $(userProc $tmp_user); do
          if [ "$op_count" = 1 ]; then
            printf "%s %d %d %d %d %d\n" $j $(uid $j) $(gid $j) $(userProcCount $j) $(user_oldest_process_pid $j) $(user_lastest_process $j) >> ${TEMPFILE}
          else
            printf "%s %d %d %d %d %d\n" $j $(uid $j) $(gid $j) $(user_total_process $j) $(user_oldest_process_pid $j) $(user_lastest_process $j) >> ${TEMPFILE}
          fi
        done
      else
        echo $TEXT_RED"User $TEXT_BOLD$tmp_user$TEXT_RESET$TEXT_RED is not connected to the system"$TEXT_RESET
      fi
    done
  done
else 
  users=$(ps ax --no-headers -ouser | sort | uniq)
  if [ "$users" = "" ]; then
    error_exit "There are no users"
  fi  
  # Itera sobre los usarios del sistema que cumplen la condicion de tiempo y guarda el resultado en un archivo temporal
  for user in $users; do
    for i in $(userProc $user); do
      if [ "$op_count" = 1 ]; then
        printf "%s %d %d %d %d %d\n" $i $(uid $i) $(gid $i) $(userProcCount $i) $(user_oldest_process_pid $i) $(user_lastest_process $i) >> ${TEMPFILE}
      else
        printf "%s %d %d %d %d %d\n" $i $(uid $i) $(gid $i) $(user_total_process $i) $(user_oldest_process_pid $i) $(user_lastest_process $i) >> ${TEMPFILE}
      fi
    done
  done
fi

# Busca que el filtro sobre el que tiene que invertir y guarda el resultado en otro archivo temporal que estara ordenado
if [ "$op_inv" = 1 ]; then
  if [ "$filter" = "-usr" ]; then
    sort -r -n -k1 < ${TEMPFILE} >> ${OUTFILE}
  elif [ "$filter" = "-count" ] || [ "$filter" = "-c" ]; then
    sort -r -n -k4 < ${TEMPFILE} >> ${OUTFILE}
  elif [ "$filter" = "-pid" ]; then
    sort -r -n -k5 < ${TEMPFILE} >> ${OUTFILE}
  else
    sort -r -k1 < ${TEMPFILE} >> ${OUTFILE}
  fi
else
  if [ "$op_pid" = 1 ]; then
    sort -n -k5 < ${TEMPFILE} >> ${OUTFILE}
  elif [ "$op_c" = 1 ]; then
    sort -n -k4 < ${TEMPFILE} >> ${OUTFILE}
  else
    sort -k1 < ${TEMPFILE} >> ${OUTFILE}
  fi
fi

# Salida por pantalla en columnas
column -t -s' ' < ${OUTFILE}

# Registramos un trap que elimine los ficheros cuando el script principal acabe
trap 'rm ${OUTFILE}' EXIT
trap 'rm ${TEMPFILE}' EXIT