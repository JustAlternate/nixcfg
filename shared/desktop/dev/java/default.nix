{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      #jdk17
      jdk11
      spark
      maven

      sbt-extras
      scala
      scalafmt
      scalafix
    ];
  };
  home.sessionVariables = {
    HADOOP_HOME = "${pkgs.hadoop_3_3}/libexec";
    SPARK_DIST_CLASSPATH = "$(${pkgs.hadoop_3_3}/bin/hadoop classpath)";
    JAVA_HOME = "${pkgs.jdk11}/lib/openjdk";
  };
}
