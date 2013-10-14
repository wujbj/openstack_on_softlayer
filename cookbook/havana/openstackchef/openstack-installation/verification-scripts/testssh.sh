ssh -o LogLevel=quiet $1 "ls" > /dev/null
echo $?
