import os
import subprocess

def get_version_code():
    try:
        with open("pubspec.yaml", "r") as f:
            for line in f:
                if line.strip().startswith("version:"):
                    parts = line.strip().split(":")
                    version_str = parts[1].strip()
                    if "+" in version_str:
                        return version_str.split("+")[1].strip()
    except Exception:
        pass
    return None

def get_fastlane_changelog(version_code):
    if not version_code:
        return None
    changelog_path = f"fastlane/metadata/android/en-US/changelogs/{version_code}.txt"
    if os.path.exists(changelog_path):
        try:
            with open(changelog_path, "r") as f:
                return f.read().strip()
        except Exception:
            pass
    return None

def get_git_changelog(current_tag):
    # Check if the tag exists in git
    tag_exists = False
    try:
        subprocess.check_call(['git', 'rev-parse', current_tag], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        tag_exists = True
    except Exception:
        tag_exists = False

    # If tag exists, compare. If not, use HEAD as current commit.
    current_ref = current_tag if tag_exists else "HEAD"

    try:
        # Find the previous tag before the current tag
        prev_tag = subprocess.check_output(
            ['git', 'describe', '--tags', '--abbrev=0', f'{current_ref}^'],
            stderr=subprocess.DEVNULL
        ).decode().strip()
    except Exception:
        prev_tag = ""

    if prev_tag:
        git_log_range = f"{prev_tag}..{current_ref}"
    else:
        git_log_range = current_ref

    try:
        log_output = subprocess.check_output(
            ['git', 'log', '--pretty=format:- %s', git_log_range]
        ).decode().strip()

        changelog_lines = []
        if log_output:
            for line in log_output.split('\n'):
                # Exclude merge commits or chore commits
                if "Merge" in line or "chore: " in line:
                    continue
                changelog_lines.append(line)
        return "\n".join(changelog_lines) if changelog_lines else "- Mejoras generales y correcciones"
    except Exception as e:
        return f"- Nuevos cambios en la release {current_tag}"

def find_apk_size(*filenames):
    candidate_dirs = [
        "build/app/outputs/flutter-apk",
        "build/app/outputs/apk/release",
    ]
    for filename in filenames:
        for directory in candidate_dirs:
            p = os.path.join(directory, filename)
            if os.path.exists(p):
                size_bytes = os.path.getsize(p)
                return f"{size_bytes / (1024 * 1024):.1f} MB"
    return "0.0 MB"

def main():
    tag_name = os.environ.get('TAG_NAME', '')
    if not tag_name:
        try:
            tag_name = subprocess.check_output(
                ['git', 'describe', '--tags', '--always']
            ).decode().strip()
        except Exception:
            tag_name = "v-dev"

    # Try loading Fastlane changelog first
    version_code = get_version_code()
    changelog = get_fastlane_changelog(version_code)

    # Fallback to git changelog if Fastlane is missing/empty
    if not changelog:
        changelog = get_git_changelog(tag_name)

    size_universal = find_apk_size("CLICK-TV-LAUNCHER-universal-release.apk", "app-release.apk")
    size_armv7 = find_apk_size("CLICK-TV-LAUNCHER-armeabi-v7a-release.apk", "app-armeabi-v7a-release.apk")
    size_arm64 = find_apk_size("CLICK-TV-LAUNCHER-arm64-v8a-release.apk", "app-arm64-v8a-release.apk")

    release_notes = f"""# CLICK TV LAUNCHER {tag_name}

Launcher libre, privado y sin anuncios para Android TV, Google TV y TV Box, desarrollado por CLICK TV DIGITAL.

## 🚀 Novedades
{changelog}

## 📦 Descargas

Elige el archivo según tu dispositivo:

| Archivo | Dispositivos | Arquitectura | Tamaño |
|:---|:---|:---|:---|
| **`CLICK-TV-LAUNCHER-universal-release.apk`** | Recomendado: funciona en todos los dispositivos compatibles | Universal | {size_universal} |
| **`CLICK-TV-LAUNCHER-arm64-v8a-release.apk`** | Televisores y TV box modernos de 64 bits | ARM de 64 bits (`arm64-v8a`) | {size_arm64} |
| **`CLICK-TV-LAUNCHER-armeabi-v7a-release.apk`** | Dispositivos antiguos de 32 bits | ARM de 32 bits (`armeabi-v7a`) | {size_armv7} |

Requisitos: Android 5.0 o posterior (API 21+).

## 💙 Apoya CLICK TV

CLICK TV LAUNCHER es gratuito y de código abierto. Si te resulta útil, puedes apoyar su desarrollo con un aporte voluntario. Consulta las opciones en la sección Donativos de la aplicación o en el [README del proyecto](https://github.com/clicktvdigital/CLICK-TV-LAUNCHER#donativos-y-apoyo-voluntario).

Enlaces oficiales de CLICK TV DIGITAL:

- [Tienda online](https://click-tv-streaming.vercel.app)
- [Contacto directo por Telegram](https://t.me/clicktvdigital)

## 📄 Licencia y créditos

Distribuido bajo GNU GPLv3. Basado en FLauncher, creado originalmente por etienn01 y mantenido por LeanBitLab; se conservan sus créditos y avisos de licencia.
"""

    with open("release_notes.md", "w") as f:
        f.write(release_notes)
    print("Successfully generated release_notes.md")

if __name__ == "__main__":
    main()
