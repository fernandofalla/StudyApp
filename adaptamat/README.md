# AdaptaMat

## Sistema Adaptativo de Aprendizaje para Matematicas de Primer Grado de Primaria

### Prototipo de Investigacion Aplicada - Universidad de San Carlos de Guatemala (USAC)
Facultad de Ingenieria - Escuela de Ciencias y Sistemas - Seminario de Investigacion

---

## 1. Descripcion General del Proyecto

AdaptaMat es un prototipo movil de aprendizaje adaptativo disenado especificamente para el area de matematicas de primer grado del nivel primario, fundamentado en el Curriculo Nacional Base (CNB) de Guatemala (MINEDUC). 

El sistema implementa un motor psicometrico basado en la Teoria de Respuesta al Item (IRT, Modelo Rasch de un parametro), acompanado de un modulo cualitativo de diagnostico heuristico de patrones de error (PE-01 al PE-06) y un panel de monitoreo diagnostico para el docente.

### Restricciones Operativas y Requisitos No Funcionales
* **RNF-01 (Hardware de gama baja):** Capacidad de ejecucion fluida en tabletas con Android 8.0+ (API 26+) y 2 GB de memoria RAM, correspondientes al programa Tecnologia en el Aula del MINEDUC.
* **RNF-02 (Tiempo de respuesta local):** Transiciones de estado y respuestas del motor adaptativo inferiores a 2 segundos (tiempos medidos < 500 ms en SQLite y BLoC).
* **RNF-05 (Offline-First estricto):** Operacion 100% autonoma sin dependencia de conectividad a internet ni servidores externos; persistencia local completa en SQLite y recursos pedagogicos incrustados en formato JSON.

---

## 2. Arquitectura del Sistema (Clean Architecture / BLoC)

El prototipo sigue el patron de Clean Architecture organizado por capas concentricas, garantizando que las reglas de negocio sean independientes de la interfaz grafica y de la infraestructura de persistencia.

### Diagrama de Componentes por Capas

```text
+-----------------------------------------------------------------------+
|                        CAPA DE PRESENTACION                           |
|  [Flutter + flutter_bloc]                                             |
|                                                                       |
|  Pantallas:                                                           |
|    - HomeScreen                - SesionScreen                         |
|    - DashboardScreen           - PerfilEstudianteScreen               |
|    - ExportacionScreen         - PruebaWidgetsScreen                  |
|                                                                       |
|  Gestores de Estado (BLoC):                                           |
|    - SesionBloc (Modulo Estudiante)                                   |
|    - DashboardBloc (Modulo Docente)                                   |
|                                                                       |
|  Widgets Especializados:                                              |
|    - ItemWidget                - FiguraWidget (CustomPainter)         |
|    - RetroalimentacionWidget   - RemediacionWidget                    |
|    - TarjetaEstudianteWidget   - BarraPatronWidget                    |
+-----------------------------------------------------------------------+
                                  |
                                  v
+-----------------------------------------------------------------------+
|                          CAPA DE DOMINIO                              |
|  [Dart puro - Reglas de Negocio sin dependencias externas]            |
|                                                                       |
|  Casos de Uso:                                                        |
|    - MotorAdaptativo (Algoritmo IRT Rasch y seleccion de items)       |
|    - DiagnosticoPatrones (6 reglas heuristicas PE-01 a PE-06)         |
|    - MapaPrerrequisitos (Grafo curricular de subtemas)                |
|    - ResumenGrupo (Metricas agregadas para el docente)                |
|                                                                       |
|  Entidades:                                                           |
|    - Estudiante   - Item   - Sesion   - Respuesta   - PatronError     |
+-----------------------------------------------------------------------+
                                  ^
                                  |
+-----------------------------------------------------------------------+
|                          CAPA DE DATOS                                |
|  [sqflite + JSON Assets]                                              |
|                                                                       |
|  Fuentes de Datos (Datasources):                                      |
|    - EstudianteDatasource       - ItemDatasource                      |
|    - SesionDatasource           - DashboardDatasource                 |
|                                                                       |
|  Persistencia Local:                                                  |
|    - DatabaseHelper (Singleton SQLite con Foreign Keys activas)       |
|    - DatabaseConstants (Constantes de tablas y columnas)              |
|    - banco_items.json (Banco de 48 items evaluativos)                 |
+-----------------------------------------------------------------------+
```

### Estructura de Directorios

```text
adaptamat/
|-- assets/
|   `-- items/
|       `-- banco_items.json              <-- Banco de 48 items curriculares
|-- lib/
|   |-- core/
|   |   |-- constants/
|   |   |   `-- database_constants.dart   <-- Nombres de tablas y columnas SQLite
|   |   `-- database/
|   |       `-- database_helper.dart      <-- Singleton SQLite, esquema y batching
|   |-- data/
|   |   `-- datasources/
|   |       |-- dashboard_datasource.dart <-- Consultas SQL agregadas para el docente
|   |       |-- estudiante_datasource.dart<-- CRUD y actualizacion de theta
|   |       `-- item_sesion_datasource.dart<-- Persistencia de sesiones y respuestas
|   |-- domain/
|   |   |-- entities/
|   |   |   |-- estudiante.dart           <-- Entidad estudiante con theta actual
|   |   |   |-- item.dart                 <-- Entidad reactivo con dificultad b
|   |   |   `-- sesion_respuesta_patron.dart <-- Modelos de sesion, acierto y patron
|   |   `-- usecases/
|   |       |-- diagnostico_patrones.dart <-- Jerarquia heuristica de patrones
|   |       |-- mapa_prerequisitos.dart   <-- Grafo curricular de dependencias
|   |       |-- motor_adaptativo.dart     <-- Funciones matematicas IRT y acotado
|   |       `-- resumen_grupo.dart        <-- Logica de clasificacion de niveles
|   |-- presentation/
|   |   |-- blocs/
|   |   |   |-- dashboard_bloc.dart       <-- Estados del panel docente
|   |   |   `-- sesion_bloc.dart          <-- Maquina de estados de practica adaptativa
|   |   |-- screens/
|   |   |   |-- dashboard_screen.dart     <-- Vista principal del docente
|   |   |   |-- exportacion_screen.dart   <-- Generacion de informe en texto plano
|   |   |   |-- home_screen.dart          <-- Menu principal y seleccion de tema
|   |   |   |-- perfil_estudiante_screen.dart <-- Historial individual y evolucion
|   |   |   |-- prueba_widgets_screen.dart<-- Vista auxiliar de depuracion
|   |   |   `-- sesion_screen.dart        <-- Interfaz de evaluacion del estudiante
|   |   `-- widgets/
|   |       |-- barra_patron_widget.dart  <-- Grafico proporcional de frecuencias
|   |       |-- figura_widget.dart        <-- Dibujo vectorial mediante CustomPainter
|   |       |-- item_widget.dart          <-- Presentador de reactivo y botones
|   |       |-- remediacion_widget.dart   <-- Tarjeta explicativa de patron detectado
|   |       |-- retroalimentacion_widget.dart <-- Notificacion inmediata de acierto
|   |       `-- tarjeta_estudiante_widget.dart <-- Tarjeta resumen en dashboard
|   `-- main.dart                         <-- Inicializacion, siembra de BD y arranque
`-- test/
    |-- usecases_test.dart                <-- 31 pruebas unitarias del dominio
    `-- widget_test.dart                  <-- Smoke test de arranque UI
```

---

## 3. Motor Adaptativo (Algoritmo IRT Rasch Simplificado)

El motor adaptativo se ubica en `lib/domain/usecases/motor_adaptativo.dart` como una clase con metodos estaticos puros, libre de efectos secundarios y completamente comprobable mediante pruebas unitarias.

### 3.1. Probabilidad Logistica de Acierto
La probabilidad de que un estudiante con nivel de habilidad $\theta$ responda correctamente un item con parametro de dificultad $b$ responde a la funcion logistica del Modelo Rasch de un parametro:

$$P(\text{correcto} \mid \theta, b) = \frac{1}{1 + e^{-(\theta - b)}}$$

En Dart se implementa utilizando `exp()` de la libreria estandar `dart:math`:
```dart
static double probabilidadCorrecta(double theta, double b) {
  return 1.0 / (1.0 + exp(-(theta - b)));
}
```

### 3.2. Regla de Actualizacion de Habilidad ($\theta$)
La actualizacion del valor estimado de habilidad utiliza una regla de paso fijo de $\pm 0.3$ logits acotado estrictamente al rango $[-3.0, +3.0]$ para prevenir divergencias numericas:

$$\theta_{t+1} = \text{clamp}(\theta_t \pm 0.3, -3.0, 3.0)$$

```dart
static double actualizarTheta(double thetaActual, bool correcto) {
  final delta = correcto ? 0.3 : -0.3;
  return (thetaActual + delta).clamp(-3.0, 3.0);
}
```

### 3.3. Seleccion Adaptativa del Siguiente Item
El sistema selecciona del banco de candidatos aquel item cuyo parametro de dificultad $b$ minimice la distancia euclidiana respecto al nivel de habilidad actual del estudiante:

$$\text{item}^* = \arg\min_{i \in \text{Candidatos}} |b_i - \theta|$$

Los items presentados se rastrean mediante un conjunto `Set<int>` para asegurar exclusion en tiempo constante $O(1)$.

### 3.4. Condicion de Dominio de Subtema
Para declarar un subtema como "dominado" y permitir el avance al siguiente nodo curricular se requiere el cumplimiento simultaneo de:
$$\theta \ge 1.0 \quad \text{y} \quad \text{items\_respondidos} \ge 5$$

### 3.5. Fase Diagnostica Inicial
Al ingresar a un subtema nuevo, el sistema extrae hasta 3 items con dificultad centrada en cero ($|b| \le 0.5$) para calibrar rapidamente la estimacion inicial de $\theta$.

---

## 4. Modulo de Diagnostico Heuristico de Patrones de Error

Ubicado en `lib/domain/usecases/diagnostico_patrones.dart`, analiza la recurrencia de distractores e historial de errores para identificar dificultades cognitivas especificas:

| Codigo | Nombre del Patron | Condicion de Activacion Heuristica | Accion Pedagogica Asociada |
| :--- | :--- | :--- | :--- |
| **PE-06** | Bloqueo sostenido | $\ge 3$ errores consecutivos al final del historial activo. | Refuerzo en definicion basica y pausa en avance. |
| **PE-05** | Sesgo a primera opcion | Seleccion del indice `0` incorrectamente $\ge 2$ veces en el historial. | Orientacion para lectura de todas las alternativas. |
| **PE-03** | Perseveracion de distractor | Eleccion del mismo distractor $\ge 2$ veces en el historial. | Recordatorio visual del concepto diferencial. |
| **PE-02** | Sobreestimacion adyacente | Seleccion del indice inmediatamente superior (`correcta + 1`). | Refuerzo en conteo exacto y operaciones basicas. |
| **PE-01** | Subestimacion adyacente | Seleccion del indice inmediatamente inferior (`correcta - 1`). | Refuerzo en correspondencia uno a uno. |
| **PE-04** | Sobreestimacion amplia | Seleccion de indice $> \text{correcta} + 1$ tras $\ge 2$ errores previos. | Explicacion grafica del orden de magnitud. |

*Jerarquia de evaluacion:* La regla general de bloqueo (PE-06) se evalua en primer lugar, seguida por los sesgos sistematicos (PE-05, PE-03), y finalmente los errores ordinales (PE-02, PE-01, PE-04).

---

## 5. Curriculo Nacional Base (CNB) y Banco de Items

El banco local (`assets/items/banco_items.json`) contiene exactamente **48 items evaluativos**, divididos equitativamente entre los dos temas seleccionados del CNB de Primer Grado:

### 5.1. Distribucion de Items

```text
[Banco de Items: 48 items]
  |
  |-- Tema 1: Numeros y Operaciones (24 items)
  |     |-- conteo                   : 6 items  (b: -2.0 a +0.8)
  |     |-- valor_posicional         : 6 items  (b: -1.2 a +1.4)
  |     |-- adicion                  : 6 items  (b: -1.0 a +1.5)
  |     `-- sustraccion              : 6 items  (b: -1.1 a +1.6)
  |
  `-- Tema 2: Geometria (24 items)
        |-- atributos_geometricos    : 8 items  (b: -1.8 a +1.5)
        |-- figuras_geometricas      : 8 items  (b: -1.4 a +1.6)
        `-- clasificacion_geometrica : 8 items  (b: -1.2 a +1.7)
```

### 5.2. Grafo de Prerrequisitos Curriculares

```text
Numeros y Operaciones:
  [conteo] --------> [valor_posicional]
     |
     `-------------> [adicion] --------> [sustraccion]

Geometria:
  [atributos_geometricos] ----> [figuras_geometricas] ----> [clasificacion_geometrica]
```

### 5.3. Renderizado de Recursos Graficos (CustomPainter)
Para cumplir con la restriccion de bajo consumo de memoria (RNF-01) y prescindir de archivos de imagen pesados, `FiguraWidget` utiliza `CustomPaint` nativo para renderizar:
* `palitos_3`: Agrupaciones lineales de conteo.
* `circulos_azules_6`: Matrices bidimensionales de puntos.
* `manzanas_8`: Elementos pictoricos con tallos.
* `cuadrado`: Cuadrilatero regular con resaltado de vertices.
* `triangulo`: Poligono de 3 lados con coordenadas vectoriales.
* `comparar_formas`: Visualizacion comparativa de 3 poligonos (3, 4 y 5 lados).
* `cubo`: Representacion isometrica tridimensional simplificada.
* `grupos_figuras`: Clasificacion visual de figuras curvas vs poligonales.

---

## 6. Persistencia y Base de Datos Local (SQLite)

La base de datos se administra mediante `DatabaseHelper` (patron Singleton) y almacena 6 tablas relacionales normalizadas:

### 6.1. Esquema Relacional

```text
+-----------------------+           +-----------------------+
|      estudiante       |           |         item          |
+-----------------------+           +-----------------------+
| id (PK)               |           | id (PK)               |
| nombre                |           | tema                  |
| grado                 |           | subtema               |
| theta_actual          |           | dificultad_b          |
| fecha_registro        |           | enunciado             |
+-----------------------+           | opciones              |
      |             |               | respuesta_correcta    |
      | 1:N         | 1:N           | codigo_patron_dist... |
      v             v               | figura                |
+-------------+ +-----------------+ +-----------------------+
|   sesion    | |  patron_error   |             |
+-------------+ +-----------------+             |
| id (PK)     | | id (PK)         |             |
| estudiant_id| | estudiante_id   |             |
| fecha_inicio| | codigo_patron   |             |
| fecha_fin   | | frecuencia      |             |
| tema        | | ultima_deteccion|             |
+-------------+ +-----------------+             |
      |                                         |
      | 1:N                                     | 1:N
      v                                         v
+-----------------------------------------------------------+
|                        respuesta                          |
+-----------------------------------------------------------+
| id (PK)                                                   |
| sesion_id (FK -> sesion.id)                               |
| item_id (FK -> item.id)                                   |
| respuesta_dada                                            |
| correcto (1 / 0)                                          |
| timestamp                                                 |
+-----------------------------------------------------------+

+-----------------------------------------------------------+
|                  contenido_remediacion                    |
+-----------------------------------------------------------+
| id (PK)                                                   |
| codigo_patron (UNIQUE) [PE-01 ... PE-06]                  |
| contenido (Texto explicativo para el estudiante)          |
+-----------------------------------------------------------+
```

### 6.2. Optimizaciones de Rendimiento e Integridad
* **Activacion de Llaves Foraneas:** Configurada mediante `onConfigure: (db) async => await db.execute('PRAGMA foreign_keys = ON;')`. Impide la insercion de registros huerfanos.
* **Transacciones por Lotes (Batching):** Las inserciones iniciales en `contenido_remediacion` y la carga masiva en `ItemDatasource.insertarLote` se ejecutan dentro de objetos `Batch`, reduciendo el I/O en almacenamiento eMMC a un solo ciclo.
* **Constantes Estaticas:** Centralizacion en `DatabaseConstants` para evitar errores tipograficos en nombres de tablas y columnas.
* **Indices Especializados:**
  * `idx_respuesta_sesion` sobre `respuesta(sesion_id)`.
  * `idx_patron_estudiante` sobre `patron_error(estudiante_id)`.
  * `idx_item_subtema` sobre `item(subtema)`.

---

## 7. Modulo Docente (Dashboard y Reportes)

El panel del docente opera como un modulo independiente desacoplado de la sesion del estudiante:

1. **Pestana "Grupo":**
   * Resumen de cada estudiante: total de sesiones, porcentaje de aciertos, fecha de ultima actividad y clasificacion cualitativa segun $\theta$:
     * *Inicio:* $\theta < 0.0$
     * *En proceso:* $0.0 \le \theta < 1.0$
     * *Logrado:* $\theta \ge 1.0$
2. **Pestana "Patrones de Error":**
   * Frecuencia acumulada del grupo para cada patron (PE-01 al PE-06) representada con barras proporcionales y conteo de estudiantes afectados.
3. **Pantalla "Perfil del Estudiante":**
   * Desglose cronologico de sesiones, evolucion de $\theta$ e historial de patrones activos.
4. **Exportacion de Resultados:**
   * Generacion de un informe de texto plano en memoria que se copia al portapapeles con un clic, eliminando dependencias de bibliotecas externas de impresion o generacion de PDF.

---

## 8. Pila Tecnologica y Dependencias

Declaradas en `pubspec.yaml`:

| Paquete | Version | Proposito |
| :--- | :--- | :--- |
| **Dart SDK** | `^3.11.5` | Lenguaje base tipado estatico |
| **Flutter SDK** | `3.41.7` | Framework UI compilado a nativo |
| **flutter_bloc** | `^8.1.5` | Separacion entre eventos, estados y presentacion |
| **sqflite** | `^2.3.2` | Base de datos relacional local SQLite |
| **equatable** | `^2.0.5` | Comparacion por valor en estados de BLoC |
| **path** | `^1.9.0` | Utilidad de rutas para SQLite |
| **cupertino_icons** | `^1.0.8` | Iconografia complementaria |

---

## 9. Instrucciones de Ejecucion y Pruebas

### 9.1. Requisitos Previos
* Flutter SDK 3.x o superior con Dart SDK integrado.
* Dispositivo fisico Android con depuracion USB o Emulador Android configurado con API 26+ (Android 8.0 o superior).

### 9.2. Comandos Principales

```bash
# Navegar a la carpeta del proyecto
cd adaptamat

# Obtener dependencias
flutter pub get

# Ejecutar el analisis estatico de codigo (cero errores o advertencias)
flutter analyze

# Ejecutar la suite completa de 31 pruebas unitarias
flutter test

# Compilar y ejecutar en dispositivo o emulador conectado
flutter run
```

---

## 10. Protocolo de Verificacion Tecnica (Pruebas del Dashboard)

Para validar la consistencia del sistema en dispositivos de prueba, ejecutar las siguientes comprobaciones:

### Prueba 1: Consistencia Dashboard vs Base de Datos
1. Ejecutar una sesion de practica completando al menos 5 items en "Numeros y Operaciones".
2. Ingresar al "Panel docente" y verificar el valor de $\theta$, el nivel (Inicio / En proceso / Logrado) y el contador de sesiones.
3. Extraer la base de datos `adaptamat.db` con Android Device File Explorer y consultar:
   ```sql
   SELECT theta_actual FROM estudiante WHERE id = 1;
   SELECT COUNT(*) FROM sesion WHERE estudiante_id = 1;
   ```
4. Confirmar que los valores en pantalla concuerden exactamente con los registros de SQLite.

### Prueba 2: Deteccion Heuristica de Patrones de Error
1. Iniciar una sesion en "Numeros y Operaciones".
2. Ante preguntas de adicion o conteo, seleccionar deliberadamente la primera opcion incorrecta repetidas veces.
3. Concluir la sesion y dirigirse a la pestana "Patrones de error" del panel docente.
4. Verificar la presencia del codigo detectado (ej. PE-05 o PE-03) y validar con:
   ```sql
   SELECT codigo_patron, frecuencia FROM patron_error WHERE estudiante_id = 1;
   ```

### Prueba 3: Exportacion de Reporte al Portapapeles
1. Desde el panel docente, presionar el icono de exportacion en la barra superior.
2. Presionar el boton "Copiar reporte".
3. Pegar el contenido en un editor de texto externo y confirmar la inclusion completa del consolidado de aula y la relacion de patrones observados.
