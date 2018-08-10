buildscript {
	repositories {
		maven {
			url "https://nexus.nmlv.nml.com/repository/nmlv/"
		}
	}
	dependencies {
            classpath("org.springframework.boot:spring-boot-gradle-plugin:2.0.1.RELEASE")
            classpath("io.spring.gradle:dependency-management-plugin:1.0.5.RELEASE")
	}
}

plugins {
	id 'java'
	id 'eclipse'
	id 'maven-publish'
	id 'jacoco'
    id 'org.springframework.boot' version '2.0.1.RELEASE'
    id 'io.spring.dependency-management' version '1.0.5.RELEASE'
}

sourceCompatibility = 1.8
targetCompatibility = 1.8

repositories {
	maven {
		url "https://nexus.nmlv.nml.com/repository/nmlv/"
	}
}
configurations {
	integrationTestCompile.extendsFrom testCompile
	integrationTestRuntime.extendsFrom testRuntime
}

bootJar {
    archiveName = 'app.jar'
    mainClassName = 'com.nm.nb.requirements.Application'
    manifest {
        attributes("Implementation-Version": version)
    }
}

bootRun {
	systemProperties System.properties
}

sourceSets {
	integrationTest {
		java {
			compileClasspath += main.output + test.output
			runtimeClasspath += main.output + test.output
			srcDir file('src/integration-test/java')
		}
		resources.srcDir file('src/integration-test/resources')
	}
}

test {
	ignoreFailures = true
	reports.html.enabled = true

	jacoco {
	 	destinationFile = file("$buildDir/jacoco/jacoco.exec")
	 	classDumpDir = file("$buildDir/jacoco/classpathdumps")
	}
}

jacocoTestReport {
     group = "Reporting"
     description = "Generate Jacoco coverage reports after running tests."
     reports {
        xml {
    		enabled true
    		destination file("$buildDir/reports/jacoco/jacoco.xml")
        }
        csv.enabled false
        html {
		  enabled true
		  destination file("$buildDir/reports/jacoco/jacocoHtml")
        }
    }
}

dependencies {
compile(
		[group: 'org.springframework.boot', name: 'spring-boot-starter-web', version: '2.0.1.RELEASE'],
		[group: 'org.springframework.boot', name: 'spring-boot-starter-actuator', version: '2.0.1.RELEASE'],
		[group: 'org.springframework.boot', name: 'spring-boot-starter-cache', version: '2.0.1.RELEASE'],
		[group: 'org.springframework.boot', name: 'spring-boot-starter-security', version: '2.0.1.RELEASE'],
		[group: 'org.springframework', name: 'spring-context-support', version: '4.3.13.RELEASE'],
		[group: 'io.springfox', name: 'springfox-swagger2', version: '2.7.0'],
		[group: 'io.springfox', name: 'springfox-swagger-ui', version: '2.7.0'],
		[group: 'org.apache.commons', name: 'commons-collections4', version: '4.1'],
		[group: 'org.apache.commons', name: 'commons-lang3', version: '3.7'],
		[group: 'commons-io', name: 'commons-io', version: '2.6'],
		[group: 'com.fasterxml.jackson.dataformat', name: 'jackson-dataformat-xml', version: '2.9.0'],
		[group: 'net.logstash.logback', name: 'logstash-logback-encoder', version: '4.9'],
		[group: 'com.nm.nbdigapp', name: 'nb-digapp-common', version: '1.0.0-SNAPSHOT', changing: true],
		[group: 'org.kie', name: 'kie-spring', version: '7.5.0.Final'],
		[group: 'org.drools', name: 'drools-decisiontables', version: '7.5.0.Final'],
		[group: 'org.drools', name: 'drools-core', version: '7.5.0.Final']
	)
	testCompile(
		[group: 'junit', name: 'junit', version: '4.12'],
		[group: 'org.springframework.boot', name: 'spring-boot-starter-test', version: '2.0.1.RELEASE']
	)
}

publishing {
	publications {
		maven(MavenPublication) {
			pom.withXml {
				asNode().dependencies.'*'.findAll() {
					it.scope.text() == 'runtime' && project.configurations.compile.allDependencies.find { dep ->
						dep.name == it.artifactId.text()
					}
				}.each() {
					it.scope*.value = 'compile'
				}
			}
			from components.java
		}
	}
}

model {
	tasks.generatePomFileForMavenPublication {
		destination = file("$buildDir/libs/pom.xml")
	}
}

check.dependsOn jacocoTestReport
check.dependsOn {tasks.findAll { task -> task.name.startsWith('generatePomFileForMavenPublication') }}