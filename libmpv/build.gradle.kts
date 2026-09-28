import com.vanniktech.maven.publish.AndroidSingleVariantLibrary

plugins {
    alias(libs.plugins.android.library)
    alias(libs.plugins.maven.publish)
}

android {
    namespace = "dev.jdtech.mpv"
    compileSdk = 36
    buildToolsVersion = "36.0.0"
    ndkVersion = "28.2.13676358"

    defaultConfig {
        minSdk = 26
        ndk {
            // LGPL build ships ARM only
            abiFilters += listOf("armeabi-v7a", "arm64-v8a")
        }
        consumerProguardFiles("proguard-rules.pro")
        externalNativeBuild {
            cmake {
                arguments += listOf(
                    "-DANDROID_STL=c++_shared",
                )
                cFlags += "-Werror"
                cppFlags += "-std=c++11"
            }
        }
    }

    externalNativeBuild {
        cmake {
            path = file("src/main/cpp/CMakeLists.txt")
            version = "4.0.2"
        }
    }
}

dependencies {
    implementation(libs.androidx.annotation)
}

mavenPublishing {
    publishToMavenCentral(automaticRelease = true)
    signAllPublications()

    configure(
        platform = AndroidSingleVariantLibrary(
            variant = "release",
            sourcesJar = true,
            publishJavadocJar = false,
        )
    )

    coordinates(
        groupId = "dev.jdtech.mpv",
        artifactId = "libmpv",
        version = "0.5.1-lgpl"
    )

    pom {
        name = "libmpv-android-lgpl"
        description = "libmpv for Android (LGPL build: mpv -Dgpl=false, FFmpeg without --enable-gpl)"
        inceptionYear = "2023"
        url = "https://github.com/jarnedemeulemeester/libmpv-android"
        licenses {
            license {
                name = "GNU Lesser General Public License v3.0 or later (native libraries); MIT (JNI wrapper)"
                url = "https://github.com/SnowMediaEnt/libmpv-android-lgpl/blob/lgpl/README.md#license"
            }
        }
        developers {
            developer {
                id = "jarnedemeulemeester"
                name = "Jarne Demeulemeester"
                email = "jarnedemeulemeester@gmail.com"
            }
        }
        scm {
            url = "https://github.com/jarnedemeulemeester/libmpv-android.git"
            connection = "scm:git@github.com:jarnedemeulemeester/libmpv-android.git"
            developerConnection = "scm:git@github.com:jarnedemeulemeester/libmpv-android.git"
        }
        issueManagement {
            system = "GitHub"
            url = "https://github.com/jarnedemeulemeester/libmpv-android/issues"
        }
    }
}
