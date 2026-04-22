import 'dart:io';

void main() async {
  print('================================================');
  print('🚀 Agente Interactivo para Enviar a GitHub 🚀');
  print('================================================\n');

  // 1. Pedir el link del nuevo repositorio
  stdout.write('🔗 Ingresa el link del repositorio de GitHub (ej. https://github.com/usuario/repo.git):\n> ');
  String? repoLink = stdin.readLineSync()?.trim();
  
  if (repoLink == null || repoLink.isEmpty) {
    print('❌ Error: El link del repositorio es obligatorio.');
    exit(1);
  }

  // 2. Pedir el mensaje del commit
  stdout.write('\n📝 Ingresa el mensaje para el commit:\n> ');
  String? commitMessage = stdin.readLineSync()?.trim();
  
  if (commitMessage == null || commitMessage.isEmpty) {
    print('⚠️ No se ingresó mensaje de commit. Usando "Primer commit" por defecto.');
    commitMessage = 'Primer commit';
  }

  // 3. Establecer rama por defecto o pedir nombre
  stdout.write('\n🌿 Ingresa el nombre de la rama (presiona Enter para usar "main" por defecto):\n> ');
  String? branchName = stdin.readLineSync()?.trim();
  
  if (branchName == null || branchName.isEmpty) {
    branchName = 'main';
  }

  print('\n------------------------------------------------');
  print('⚙️ Iniciando proceso de envío a GitHub...');
  print('------------------------------------------------\n');

  try {
    // Inicializar git si no lo está
    await runCommand('git', ['init'], 'Inicializando repositorio local (git init)...');

    // Añadir todos los archivos
    await runCommand('git', ['add', '.'], 'Añadiendo archivos al stage (git add .)...');

    // Hacer el commit
    // Se ignora el error si no hay cambios nuevos para confirmar
    await runCommand('git', ['commit', '-m', commitMessage], 'Creando commit (git commit)...', ignoreError: true);

    // Cambiar a la rama seleccionada
    await runCommand('git', ['branch', '-M', branchName], 'Configurando la rama principal a "$branchName"...');

    // Configurar remote
    // Removemos el origin actual si existe para actualizarlo con el nuevo
    await runCommand('git', ['remote', 'remove', 'origin'], 'Verificando remotos antiguos...', ignoreError: true);
    await runCommand('git', ['remote', 'add', 'origin', repoLink], 'Enlazando con el repositorio remoto...');

    // Push al repositorio
    print('⏳ Subiendo archivos a GitHub (esto puede tardar unos momentos)...');
    var pushResult = await Process.run('git', ['push', '-u', 'origin', branchName]);
    
    if (pushResult.exitCode != 0) {
      print('\n❌ Error al subir a GitHub:');
      print(pushResult.stderr);
      print('Asegúrate de que el link sea correcto, tengas los permisos necesarios o el repositorio remoto no contenga cambios conflictivos.');
    } else {
      print('\n✅ ¡Repositorio enviado a GitHub con éxito! 🎉');
      print('🌐 Puedes revisarlo en: ${repoLink.replaceAll(".git", "")}');
    }

  } catch (e) {
    print('\n❌ Ocurrió un error inesperado: $e');
  }
}

Future<void> runCommand(String executable, List<String> arguments, String message, {bool ignoreError = false}) async {
  print('⏳ $message');
  var result = await Process.run(executable, arguments);
  if (result.exitCode != 0 && !ignoreError) {
    print('\n❌ Error ejecutando comando: $executable ${arguments.join(' ')}');
    print(result.stderr);
    exit(1);
  }
}
