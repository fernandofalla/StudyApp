═══════════════════════════════════════════════════════════════════════════════
GUÍA DE INICIO — ADAPTAMAT
Módulo estudiante — Primera versión funcional
═══════════════════════════════════════════════════════════════════════════════

PREREQUISITOS
─────────────
Antes de escribir una sola línea de código verificar que tienes instalado:
  - Flutter SDK 3.x o superior
  - Dart SDK incluido con Flutter
  - VS Code con las extensiones:
      · Flutter (dart-code.flutter)
      · Dart (dart-code.dart-code)
      · Pubspec Assist (opcional pero útil)
  - Android Studio solo para el emulador Android (no necesitas usarlo como editor)
  - Un emulador Android configurado con API 26 o superior (Android 8.0)
    o un dispositivo físico Android conectado con depuración USB activada

Para verificar que todo está bien antes de crear el proyecto:
  flutter doctor

Todos los ítems deben aparecer con ✓ o al menos sin errores críticos.

═══════════════════════════════════════════════════════════════════════════════
FASE 1 — CREAR EL PROYECTO
═══════════════════════════════════════════════════════════════════════════════

1. Abrir la terminal en VS Code (Ctrl + `)

2. Navegar a la carpeta donde quieres crear el proyecto:
   cd Documents  (o la carpeta que prefieras)

3. Crear el proyecto Flutter:
   flutter create adaptamat

4. Entrar al proyecto:
   cd adaptamat

5. Abrir en VS Code:
   code .

6. Verificar que corre antes de tocar nada:
   flutter run
   Debe aparecer la app de contador por defecto de Flutter.
   Si corre, el entorno está bien. Cerrar con Ctrl+C.

═══════════════════════════════════════════════════════════════════════════════
FASE 2 — ESTRUCTURA DE CARPETAS
═══════════════════════════════════════════════════════════════════════════════

Dentro de lib/ crear la siguiente estructura de carpetas manualmente
o con los comandos siguientes desde la raíz del proyecto:

mkdir -p lib/core/database
mkdir -p lib/core/constants
mkdir -p lib/domain/entities
mkdir -p lib/domain/usecases
mkdir -p lib/data/datasources
mkdir -p lib/presentation/blocs
mkdir -p lib/presentation/screens
mkdir -p lib/presentation/widgets
mkdir -p assets/items

La estructura final de lib/ debe verse así:

lib/
├── core/
│   ├── database/
│   │   └── database_helper.dart       ← esquema SQLite
│   └── constants/
│       └── app_constants.dart         ← constantes globales
├── domain/
│   ├── entities/
│   │   ├── estudiante.dart
│   │   ├── item.dart
│   │   └── sesion_respuesta_patron.dart
│   └── usecases/
│       ├── motor_adaptativo.dart      ← lógica IRT Rasch
│       ├── diagnostico_patrones.dart  ← reglas heurísticas
│       └── mapa_prerequisitos.dart    ← grafo de subtemas
├── data/
│   └── datasources/
│       ├── estudiante_datasource.dart
│       └── item_sesion_datasource.dart
├── presentation/
│   ├── blocs/
│   │   └── sesion_bloc.dart           ← gestión de estado
│   ├── screens/
│   │   ├── home_screen.dart
│   │   └── sesion_screen.dart
│   └── widgets/
│       ├── item_widget.dart
│       ├── retroalimentacion_widget.dart
│       └── remediacion_widget.dart
└── main.dart

assets/
└── items/
    └── banco_items.json               ← ítems del banco

═══════════════════════════════════════════════════════════════════════════════
FASE 3 — DEPENDENCIAS
═══════════════════════════════════════════════════════════════════════════════

Abrir pubspec.yaml y reemplazar la sección dependencies con lo siguiente:

dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.3.2
  path: ^1.9.0
  flutter_bloc: ^8.1.5
  equatable: ^2.0.5

Y agregar la sección flutter al final del archivo:

flutter:
  uses-material-design: true
  assets:
    - assets/items/

Luego ejecutar en terminal:
  flutter pub get

Verificar que no haya errores antes de continuar.

═══════════════════════════════════════════════════════════════════════════════
COMMITS SUGERIDOS — MÓDULO ESTUDIANTE
═══════════════════════════════════════════════════════════════════════════════

Los commits están ordenados de menor a mayor complejidad.
Cada commit debe dejar la app en un estado que compile y corra
sin errores antes de pasar al siguiente.

───────────────────────────────────────────────────────────────────────────────
COMMIT 01 — Estructura base y dependencias
───────────────────────────────────────────────────────────────────────────────
Qué hacer:
  - Crear todas las carpetas de la estructura descrita en Fase 2
  - Agregar las dependencias en pubspec.yaml
  - Ejecutar flutter pub get
  - Dejar main.dart con un MaterialApp vacío que muestre
    solo un Scaffold con un texto "AdaptaMat" centrado
  - Crear el archivo assets/items/banco_items.json vacío (solo [])

Archivos que se crean o modifican:
  pubspec.yaml
  lib/main.dart
  assets/items/banco_items.json

Verificación antes de commitear:
  flutter run → debe mostrar pantalla con texto "AdaptaMat"
  flutter analyze → cero errores

Mensaje de commit:
  "feat: estructura base del proyecto y dependencias iniciales"

───────────────────────────────────────────────────────────────────────────────
COMMIT 02 — Entidades del dominio
───────────────────────────────────────────────────────────────────────────────
Qué hacer:
  Crear las clases de entidades puras (sin lógica, solo propiedades):

  lib/domain/entities/estudiante.dart
    - id (int?)
    - nombre (String)
    - grado (String)
    - thetaActual (double, default 0.0)
    - fechaRegistro (DateTime)
    - método copyWith()

  lib/domain/entities/item.dart
    - id (int?)
    - tema (String)
    - subtema (String)
    - dificultadB (double)
    - enunciado (String)
    - opciones (List<String>)
    - respuestaCorrecta (int)
    - codigoPatronDistractor (String?)

  lib/domain/entities/sesion_respuesta_patron.dart
    - Clase Sesion: id, estudianteId, fechaInicio, fechaFin, tema
    - Clase Respuesta: id, sesionId, itemId, respuestaDada, correcto, timestamp
    - Clase PatronError: id, estudianteId, codigoPatron, frecuencia, ultimaDeteccion

Estas clases no importan nada externo, son Dart puro.

Verificación antes de commitear:
  flutter analyze → cero errores

Mensaje de commit:
  "feat: entidades del dominio (Estudiante, Item, Sesion, Respuesta, PatronError)"

───────────────────────────────────────────────────────────────────────────────
COMMIT 03 — Base de datos SQLite
───────────────────────────────────────────────────────────────────────────────
Qué hacer:
  Crear lib/core/database/database_helper.dart con:
  - Clase DatabaseHelper como singleton
  - Método _initDatabase() que abre adaptamat.db
  - Método _onCreate() que crea las 6 tablas:
      · estudiante
      · item
      · sesion
      · respuesta
      · patron_error
      · contenido_remediacion
  - Índices para las consultas frecuentes:
      · idx_respuesta_sesion en respuesta(sesion_id)
      · idx_patron_estudiante en patron_error(estudiante_id)
      · idx_item_subtema en item(subtema)
  - Inserción inicial del contenido de remediación
    para los 6 patrones de error (PE-01 al PE-06)

Importante: cada tabla debe tener exactamente las columnas
definidas en la Tabla 2.7 del Capítulo 2. No agregar columnas
extra en esta versión.

Verificación antes de commitear:
  flutter analyze → cero errores
  Agregar un print temporal en main.dart que llame a
  DatabaseHelper().database y verificar que no lanza excepción al correr.

Mensaje de commit:
  "feat: esquema SQLite con 6 tablas e índices de consulta"

───────────────────────────────────────────────────────────────────────────────
COMMIT 04 — Datasources de datos
───────────────────────────────────────────────────────────────────────────────
Qué hacer:
  Crear lib/data/datasources/estudiante_datasource.dart con:
  - insertar(Estudiante) → Future<int>
  - obtenerTodos() → Future<List<Estudiante>>
  - obtenerPorId(int) → Future<Estudiante?>
  - actualizarTheta(int id, double nuevoTheta) → Future<void>

  Crear lib/data/datasources/item_sesion_datasource.dart con:

  Clase ItemDatasource:
  - insertarLote(List<Item>) → Future<void>
  - obtenerPorSubtema(String) → Future<List<Item>>
  - obtenerTodos() → Future<List<Item>>
  - bancoVacio() → Future<bool>

  Clase SesionDatasource:
  - iniciarSesion(Sesion) → Future<int>
  - cerrarSesion(int sesionId) → Future<void>
  - registrarRespuesta(Respuesta) → Future<int>
  - obtenerRespuestasDeSesion(int) → Future<List<Respuesta>>
  - registrarOActualizarPatron(estudianteId, codigoPatron) → Future<void>
  - obtenerContenidoRemediacion(String) → Future<String?>
  - obtenerPatronesDeEstudiante(int) → Future<List<PatronError>>

Verificación antes de commitear:
  flutter analyze → cero errores

Mensaje de commit:
  "feat: datasources para estudiante, ítems y sesiones"

───────────────────────────────────────────────────────────────────────────────
COMMIT 05 — Banco de ítems JSON
───────────────────────────────────────────────────────────────────────────────
Qué hacer:
  Llenar assets/items/banco_items.json con al menos 18 ítems
  distribuidos así:
  - 4 ítems de subtema "conteo"
  - 3 ítems de subtema "valor_posicional"
  - 3 ítems de subtema "adicion"
  - 2 ítems de subtema "sustraccion"
  - 3 ítems de subtema "atributos_geometricos"
  - 2 ítems de subtema "figuras_geometricas"
  - 1 ítem de subtema "clasificacion_geometrica"

  Cada ítem debe tener:
  {
    "tema": "numeros_y_operaciones",
    "subtema": "conteo",
    "dificultad_b": -1.5,
    "enunciado": "...",
    "opciones": ["op1", "op2", "op3", "op4"],
    "respuesta_correcta": 1,
    "codigo_patron_distractor": "PE-01"
  }

  Los valores de dificultad_b deben distribuirse entre -2.0 y +2.0
  para que el motor adaptativo tenga rango de selección.

  Actualizar main.dart para que al iniciar:
  1. Verifique si el banco está vacío con bancoVacio()
  2. Si está vacío, lea el JSON con rootBundle.loadString()
  3. Inserte los ítems con insertarLote()

Verificación antes de commitear:
  flutter run → al iniciar no debe lanzar errores en consola
  Agregar un print que muestre cuántos ítems se cargaron

Mensaje de commit:
  "feat: banco de ítems JSON con 18 ítems calibrados para primer grado"

───────────────────────────────────────────────────────────────────────────────
COMMIT 06 — Casos de uso del dominio
───────────────────────────────────────────────────────────────────────────────
Qué hacer:
  Crear lib/domain/usecases/motor_adaptativo.dart con:
  - probabilidadCorrecta(theta, b) → double
    Fórmula: 1 / (1 + e^(-(θ - b)))
  - actualizarTheta(thetaActual, correcto) → double
    Regla: +0.3 si correcto, -0.3 si incorrecto, clamp [-3, +3]
  - seleccionarSiguienteItem(theta, subtema, banco, presentados) → Item?
    Criterio: ítem con b más cercano a theta, no presentado aún
  - evaluarDominio(theta, itemsRespondidos) → bool
    Criterio: theta >= 1.0 y itemsRespondidos >= 5
  - seleccionarItemsDiagnostico(subtema, banco) → List<Item>
    Criterio: ítems con dificultadB.abs() <= 0.5, máximo 3

  Crear lib/domain/usecases/diagnostico_patrones.dart con:
  - evaluar(historial, subtema, respuestaDada, respuestaCorrecta, correcto)
    → String? (código del patrón o null)
    Implementar las 6 reglas heurísticas de la Tabla 2.6

  Crear lib/domain/usecases/mapa_prerequisitos.dart con:
  - subtemaInicial(tema) → String
  - siguienteSubtema(subtemaActual) → String?
  - estaDisponible(subtema, subtemasDominados) → bool
  - subtemasDeTema(tema) → List<String>

  Estos archivos son Dart puro, sin imports de Flutter ni sqflite.

Verificación antes de commitear:
  flutter analyze → cero errores
  Escribir un test manual en main.dart:
    print(MotorAdaptativo.actualizarTheta(0.0, true)); // debe imprimir 0.3
    print(MotorAdaptativo.evaluarDominio(theta: 1.1, itemsRespondidos: 5)); // true

Mensaje de commit:
  "feat: casos de uso del dominio (motor adaptativo, diagnóstico, prerrequisitos)"

───────────────────────────────────────────────────────────────────────────────
COMMIT 07 — SesionBloc (gestión de estado)
───────────────────────────────────────────────────────────────────────────────
Qué hacer:
  Crear lib/presentation/blocs/sesion_bloc.dart con:

  Eventos:
  - IniciarSesion(estudianteId, thetaInicial, tema)
  - ResponderItem(respuestaDada)
  - ContinuarTrasRemediacion()
  - FinalizarSesion()

  Estados:
  - SesionInicial
  - SesionCargando
  - SesionConItem(item, theta, itemsRespondidos, subtemaActivo)
  - SesionRetroalimentacion(correcto, respuestaCorrecta)
  - SesionRemediacion(codigoPatron, contenido)
  - SesionSubtemaDominado(subtema, siguienteSubtema)
  - SesionFinalizada(thetaFinal, itemsRespondidos)
  - SesionError(mensaje)

  El BLoC coordina:
  1. Al recibir IniciarSesion: cargar banco, seleccionar ítems diagnóstico
  2. Al recibir ResponderItem: registrar respuesta, actualizar theta,
     detectar patrón, emitir retroalimentación o remediación
  3. Al recibir ContinuarTrasRemediacion: seleccionar siguiente ítem
  4. Al recibir FinalizarSesion: cerrar sesión en BD

Verificación antes de commitear:
  flutter analyze → cero errores
  No es necesario que se vea en pantalla aún, solo que compile.

Mensaje de commit:
  "feat: SesionBloc con eventos, estados y lógica de coordinación"

───────────────────────────────────────────────────────────────────────────────
COMMIT 08 — Widgets de presentación
───────────────────────────────────────────────────────────────────────────────
Qué hacer:
  Crear lib/presentation/widgets/item_widget.dart
    - Muestra el enunciado del ítem en una Card
    - Muestra 4 botones de opción (altura mínima 64dp)
    - Al seleccionar una opción llama onRespuesta(indice)
    - Deshabilita los botones tras seleccionar (evitar doble tap)
    - Fondo blanco, texto oscuro, borde azul oscuro (#1F3864)

  Crear lib/presentation/widgets/retroalimentacion_widget.dart
    - Ícono grande: check verde si correcto, X roja si incorrecto
    - Texto "¡Correcto!" o "Incorrecto"
    - Si incorrecto: muestra la respuesta correcta
    - Botón "Continuar" que llama onContinuar()

  Crear lib/presentation/widgets/remediacion_widget.dart
    - Ícono de bombilla amarilla
    - Texto "Recuerda:"
    - Card con el contenido de remediación
    - Botón "Entendido, continuar" que llama onContinuar()

  Todos los botones deben tener height >= 56 para cumplir RNF-03.
  Fuente Arial o sans-serif, tamaño mínimo 16sp en botones.

Verificación antes de commitear:
  Crear una pantalla de prueba temporal que muestre cada widget
  con datos hardcodeados para verificar que se ven bien visualmente.
  flutter run → verificar apariencia en el emulador.

Mensaje de commit:
  "feat: widgets de ítem, retroalimentación y remediación"

───────────────────────────────────────────────────────────────────────────────
COMMIT 09 — Pantallas principales
───────────────────────────────────────────────────────────────────────────────
Qué hacer:
  Crear lib/presentation/screens/home_screen.dart
    - Muestra el nombre del estudiante
    - Dos botones grandes: "Números y Operaciones" y "Geometría"
    - Al pulsar un botón navega a SesionScreen con el tema seleccionado
    - Carga el estudiante desde EstudianteDatasource al iniciar

  Crear lib/presentation/screens/sesion_screen.dart
    - AppBar con el nombre del tema activo
    - Cuerpo que muestra el widget correspondiente al estado del BLoC:
        · SesionCargando → CircularProgressIndicator
        · SesionConItem → ItemWidget
        · SesionRetroalimentacion → RetroalimentacionWidget
        · SesionRemediacion → RemediacionWidget
        · SesionFinalizada → pantalla de resumen con theta final
        · SesionError → texto de error
    - BlocConsumer que escucha SesionSubtemaDominado
      y muestra un AlertDialog de logro

  Actualizar main.dart para:
    - Crear estudiante de prueba si no existe ninguno
    - Usar HomeScreen como pantalla inicial
    - Proveer el SesionBloc con BlocProvider

Verificación antes de commitear:
  flutter run → debe poder navegar de HomeScreen a SesionScreen
  y ver el primer ítem en pantalla al seleccionar un tema.

Mensaje de commit:
  "feat: pantallas HomeScreen y SesionScreen con navegación funcional"

───────────────────────────────────────────────────────────────────────────────
COMMIT 10 — Integración completa y prueba del flujo
───────────────────────────────────────────────────────────────────────────────
Qué hacer:
  Verificar el flujo completo de principio a fin:
  1. App inicia → carga banco de ítems → muestra HomeScreen
  2. Seleccionar "Números y Operaciones"
  3. Aparecen 3 ítems de diagnóstico inicial (b ≈ 0.0)
  4. Responder correctamente → theta sube → retroalimentación verde
  5. Responder incorrectamente → theta baja → retroalimentación roja
  6. Si se activa un patrón → aparece remediación
  7. Al alcanzar theta >= 1.0 con 5+ ítems → AlertDialog de dominio
  8. Avanzar al siguiente subtema o finalizar sesión
  9. Pantalla de resumen con theta final e ítems respondidos

  Corregir cualquier error que aparezca durante la prueba del flujo.

  Agregar manejo básico de errores:
  - Si el banco está vacío al iniciar sesión → mostrar SesionError
  - Si no hay más ítems disponibles → finalizar sesión automáticamente

  Limpiar prints de depuración temporales antes de commitear.

Verificación antes de commitear:
  Completar el flujo completo al menos 2 veces sin que la app se cierre.
  flutter analyze → cero errores o warnings.

Mensaje de commit:
  "feat: flujo completo del módulo estudiante funcional e integrado"

═══════════════════════════════════════════════════════════════════════════════
NOTAS IMPORTANTES
═══════════════════════════════════════════════════════════════════════════════

1. Nunca pasar al commit siguiente si el actual no compila.
   Un commit roto es peor que no commitear.

2. Usar nombres de variables en español para mantener consistencia
   con la nomenclatura del Capítulo 2 y el Capítulo 3.

3. Cada archivo debe tener un comentario en la primera línea
   indicando a qué capa pertenece y su propósito, por ejemplo:
   // lib/domain/usecases/motor_adaptativo.dart
   // Capa de dominio — Lógica de selección de ítems IRT Rasch simplificado

4. El emulador recomendado para pruebas es Pixel 7 API 33 o superior.
   Para probar en condiciones reales usar una tableta de gama baja
   con Android 8.0 si está disponible.

5. Si en algún commit aparece el error "MissingPluginException" al usar
   sqflite, ejecutar:
   flutter clean
   flutter pub get
   flutter run

6. El Capítulo 3 se redacta en paralelo a los commits, documentando
   las decisiones técnicas tomadas en cada uno. No dejarlo para el final.

═══════════════════════════════════════════════════════════════════════════════

