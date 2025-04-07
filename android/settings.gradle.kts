pluginManagement {
    val flutterSdkPath = File(System.getenv("FLUTTER_SDK") ?: run {
        val localProperties = File("local.properties")
        if (localProperties.exists()) {
            val properties = java.util.Properties().apply {
                localProperties.inputStream().use { load(it) }
            }
            properties.getProperty("flutter.sdk")?.let { File(it) }
        } else null
    } ?: throw GradleException("""
        Flutter SDK not found. Define location with either:
        1. FLUTTER_SDK environment variable
        2. flutter.sdk in local.properties
    """.trimIndent())

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.name = "pulse_with_backend"
include(":app")