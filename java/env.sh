if [ -f "/usr/libexec/java_home" ]; then
	JAVA8=$(/usr/libexec/java_home -v 1.8)
	export JAVA_HOME=$JAVA8
fi