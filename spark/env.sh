SPARK_HOME="Documents/modeling/spark-1.5.2-bin-hadoop2.6"
if [[ -d $SPARK_HOME ]]; then
	pathprepend $SPARK_HOME/bin
	pathprepend $SPARK_HOME/sbin
fi
