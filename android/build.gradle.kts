// android\build.gradle.kts
buildscript {
    dependencies {
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:2.2.21")
        classpath("org.jetbrains.kotlin:kotlin-serialization:2.2.21")
    }
    repositories {
        google()
        mavenCentral()
    }
}

val rootBuildDir: Directory = rootProject.layout.projectDirectory.dir("../build")
rootProject.layout.buildDirectory.value(rootBuildDir)

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

subprojects {
    val projectBuildDir = rootBuildDir.dir(project.name)
    project.layout.buildDirectory.value(projectBuildDir)

    configurations.configureEach {
        resolutionStrategy {
            force("androidx.core:core:1.15.0")
            force("androidx.core:core-ktx:1.15.0")
            force("androidx.browser:browser:1.8.0")
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}