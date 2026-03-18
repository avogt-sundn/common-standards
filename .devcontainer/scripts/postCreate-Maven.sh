#!/usr/bin/env bash

mkdir -p $HOME/.m2
sudo chown -R vscode:vscode /home/vscode/.m2

if curl -sf --max-time 3 http://maven-mirror:8080/central > /dev/null 2>&1; then
  cat > $HOME/.m2/settings.xml<<EOF
<settings>
    <mirrors>
        <mirror>
            <id>dockerized-mirror</id>
            <name>Local Mirror Repository</name>
            <url>http://maven-mirror:8080/central</url>
            <mirrorOf>central</mirrorOf>
        </mirror>
    </mirrors>
</settings>
EOF
  echo "Maven mirror is reachable — using http://maven-mirror:8080/central"
else
  cat > $HOME/.m2/settings.xml<<EOF
<settings>
    <!-- maven-mirror not reachable at container start — using Maven Central directly -->
</settings>
EOF
  echo "Maven mirror is not reachable — falling back to Maven Central"
fi
