# Game Design Document
## Runas del Núcleo

**Versión:** 1.0 MVP  
**Fecha:** Noviembre 2025  
**Género:** Action-Adventure, Top-Down, Puzzle  
**Plataformas:** Windows, Web (HTML5)  
**Duración Estimada:** 45-60 minutos  
**Público Objetivo:** 12+ años

---

## 1. CONCEPTO PRINCIPAL

### 1.1 High Concept
Un juego de acción top-down donde el jugador combina runas elementales para crear habilidades únicas, resolviendo puzzles y derrotando enemigos en un bosque místico corrupto.

### 1.2 Pilares de Diseño
1. **Simplicidad Estratégica:** Pocas opciones pero cada una significativa
2. **Combinación Creativa:** El poder está en combinar, no acumular
3. **Riesgo/Recompensa:** Cooldowns y maná obligan a decisiones tácticas
4. **Exploración Compacta:** Mundo pequeño pero denso en contenido

### 1.3 Core Loop
```
Explorar → Encontrar Enemigos/Puzzles → Usar Runas Estratégicamente → 
Avanzar → Enfrentar Jefe → Victoria
```

**Bucle Táctico (cada encuentro):**
1. Evaluar situación (enemigos, obstáculos)
2. Elegir combinación de runas
3. Ejecutar habilidad
4. Esperar cooldown
5. Adaptar estrategia

---

## 2. MECÁNICAS FUNDAMENTALES

### 2.1 Movimiento del Jugador

**Sistema:** Top-down, 8 direcciones

**Controles:**
- **WASD:** Movimiento en 8 direcciones
- Velocidad base: **4 unidades/segundo**
- Sin aceleración (respuesta instantánea)
- Mantener diagonal = misma velocidad que cardinal

**Especificaciones Técnicas:**
```
Velocidad diagonal: velocidad_base * 0.707 (normalizado)
Radio de colisión del jugador: 0.4 unidades
Tamaño visual del jugador: 1x1 unidad (32x32 píxeles)
```

### 2.2 Sistema de Combate Básico

**Ataque Cuerpo a Cuerpo:**
- **Tecla:** Click Izquierdo del Mouse
- **Daño:** 3 puntos
- **Alcance:** 1.2 unidades (frontal, arco de 90°)
- **Cooldown:** 0.5 segundos
- **Animación:** 0.2 segundos
- **Knockback:** 0.2 unidades al enemigo

**Comportamiento:**
- Ataca en la dirección del mouse (prioridad) o última dirección de movimiento
- Durante la animación, velocidad reducida al 50%
- No consume maná
- Puede cancelarse con Dash (Runa de Movimiento)

### 2.3 Sistema de Estadísticas del Jugador

**Vida:**
- Vida Máxima: **20 HP**
- Regeneración: NO (solo mediante items/checkpoints si se agregan post-MVP)
- Muerte: Reinicio desde inicio de sala actual

**Maná:**
- Maná Máximo: **50 puntos**
- Regeneración: **2 puntos/segundo** (comienza 1 segundo después del último uso)
- Visual: Barra azul bajo la vida

**Invulnerabilidad Post-Daño:**
- Duración: **1 segundo**
- Visual: Parpadeo del sprite (4 flashes)

---

## 3. SISTEMA DE RUNAS

### 3.1 Controles de Selección

**Mapeo de Teclas:**
- **E:** Seleccionar Runa de Fuego
- **R:** Seleccionar Runa de Escudo
- **T:** Seleccionar Runa de Movimiento
- **Espacio:** Confirmar combinación Y ejecutar habilidad individual
- **TAB:** Cancelar selección actual
- **Click Derecho:** Alternativa a Espacio

### 3.2 Flujo de Selección (FSM)

**Estados:**

1. **IDLE (Sin selección)**
   - Presionar E/R/T → Cambia a FIRST_SELECTED
   - Mostrar: UI normal

2. **FIRST_SELECTED (Una runa seleccionada)**
   - Highlight en runa seleccionada (borde dorado + brillo)
   - Presionar misma tecla → Mantiene selección
   - Presionar otra runa (E/R/T) → Cambia a COMBO_READY
   - Presionar Espacio → Ejecuta runa individual + vuelve a IDLE
   - Presionar TAB → Vuelve a IDLE

3. **COMBO_READY (Dos runas seleccionadas)**
   - Highlight en ambas runas + icono de combinación entre ellas
   - Texto en pantalla: "ESPACIO para combinar"
   - Presionar Espacio → Ejecuta combinación + vuelve a IDLE
   - Presionar TAB → Vuelve a IDLE
   - No se puede seleccionar tercera runa

4. **COOLDOWN (Habilidad en enfriamiento)**
   - Runa(s) en gris con temporizador visible
   - No se puede seleccionar hasta que termine
   - Otros runas disponibles siguen seleccionables

**Restricciones:**
- No se puede cambiar selección durante animación de habilidad (0.2-0.5s)
- Solo 1 habilidad activa simultáneamente
- Input buffering: NO (presionar tecla durante animación = ignorado)

### 3.3 Runas Individuales

#### RUNA DE FUEGO
**Nombre:** Toque de Fuego

**Estadísticas:**
- **Tipo:** Buff temporal
- **Duración:** 8 segundos
- **Cooldown:** 10 segundos
- **Costo Maná:** 6 puntos
- **Buff de Daño:** +30% multiplicativo a todos los ataques
- **Quemadura Aplicada:** 1 HP/segundo por 4 segundos (en cada golpe)

**Comportamiento:**
1. Al activarse:
   - Arma del jugador brilla con aura naranja/roja
   - Partículas de fuego emanan del jugador
   - Todos los ataques (básicos y habilidades) aplican quemadura
2. La quemadura es un DoT (Damage over Time):
   - Stackeable: Múltiples golpes resetean duración, no suman daño
   - Visual: Enemigo con sprite naranja parpadeante
3. Se cancela al terminar duración o al morir el jugador

**VFX:**
- Activación: Flash naranja + partículas ascendentes
- Activo: Trail de fuego en arma
- Golpe con buff: Pequeña explosión de chispas

**SFX:**
- Activación: "Whoosh" + crepitar de fuego
- Golpe con buff: Sonido de impacto + chisporroteo

---

#### RUNA DE MOVIMIENTO
**Nombre:** Destello

**Estadísticas:**
- **Tipo:** Dash/Desplazamiento
- **Distancia:** 5 unidades
- **Duración Animación:** 0.15 segundos
- **Cooldown:** 8 segundos
- **Costo Maná:** 5 puntos
- **Invulnerabilidad:** Durante toda la animación (0.15s)

**Comportamiento:**
1. Desplazamiento instantáneo en dirección del input (WASD):
   - Si WASD está presionado: Dash en esa dirección
   - Si no hay input: Dash hacia donde mira el mouse
   - Si no hay mouse: Dash hacia última dirección de movimiento
2. Atraviesa enemigos (no colisiona durante dash)
3. NO atraviesa paredes ni obstáculos sólidos:
   - Si hay pared en el camino, se detiene al colisionar
4. Cancela animaciones actuales (ataque básico)

**Casos Especiales:**
- Dash hacia pared: Se detiene inmediatamente, sin rebote
- Dash sobre enemigo: Jugador sale del otro lado sin daño
- Dash durante knockback: Cancela el knockback

**VFX:**
- Inicio: Estela blanca/azul en posición inicial
- Durante: Motion blur del sprite
- Fin: Pequeña onda expansiva al aterrizar

**SFX:**
- Inicio: "Swoosh" agudo
- Durante: Sonido de viento cortado
- Fin: "Thump" suave al aterrizar

---

#### RUNA DE ESCUDO
**Nombre:** Campo de Fuerza

**Estadísticas:**
- **Tipo:** Escudo temporal
- **Duración Máxima:** 5 segundos
- **Durabilidad:** 12 HP
- **Cooldown:** 14 segundos
- **Costo Maná:** 8 puntos
- **Reducción de Daño:** 40% del daño excedente (al romperse)

**Comportamiento:**
1. Crea escudo circular de 1.5 unidades de radio alrededor del jugador
2. Mecánica de absorción:
   - El escudo recibe TODO el daño antes que el jugador
   - Ejemplo: Enemigo golpea por 5 HP → Escudo pierde 5 HP, jugador 0 HP
3. Si el escudo se rompe (0 HP):
   - Se destruye inmediatamente
   - Jugador recibe 40% de reducción de daño durante 1 segundo
   - Ejemplo: Si recibe 10 HP justo al romperse → solo pierde 6 HP
4. Si termina la duración sin romperse:
   - Desaparece sin bonus adicional

**Interacciones:**
- Se puede usar Destello con escudo activo (el escudo se mueve con el jugador)
- Combinaciones pueden usarse con escudo activo
- Knockback afecta al jugador normalmente, el escudo se mueve con él

**VFX:**
- Activación: Hexágonos azules expandiéndose desde el centro
- Activo: Domo semitransparente azul con patrón hexagonal
- Al recibir daño: Ondas concéntricas desde punto de impacto
- Al romperse: Fragmentos de cristal dispersándose

**SFX:**
- Activación: Zumbido eléctrico ascendente
- Activo: Zumbido bajo constante
- Impacto: "Ding" cristalino + eco
- Rotura: Sonido de cristal quebrándose

---

### 3.4 Combinaciones de Runas

#### COMBINACIÓN 1: FUEGO + MOVIMIENTO
**Nombre:** Dardo Ígneo

**Estadísticas:**
- **Tipo:** Proyectil direccional
- **Daño:** 6 puntos
- **Velocidad:** 10 unidades/segundo
- **Alcance Máximo:** 15 unidades
- **Cooldown:** 12 segundos (aplica a AMBAS runas)
- **Costo Maná:** 10 puntos
- **Penetración:** 1 enemigo

**Comportamiento:**
1. Dirección de disparo (prioridad):
   - Hacia posición del mouse (si está en pantalla)
   - Si no: Última dirección de movimiento (WASD)
   - Si jugador está quieto sin mouse: Hacia arriba por defecto
2. Proyectil:
   - Atraviesa el PRIMER enemigo que golpea
   - Desaparece al golpear el SEGUNDO enemigo
   - NO atraviesa paredes ni obstáculos sólidos
   - Se destruye al alcanzar distancia máxima
3. Interacción con objetos:
   - Destruye objetos frágiles (cajas, jarrones) instantáneamente
   - No empuja bloques empujables

**VFX:**
- Proyectil: Esfera de fuego con trail de partículas
- Impacto en enemigo: Pequeña explosión de llamas
- Impacto en pared: Chispas dispersándose
- Desaparición por alcance: Fade out con partículas cayendo

**SFX:**
- Disparo: "Fwoosh" + crepitar
- Vuelo: Silbido bajo continuo
- Impacto: "Boom" apagado + crujido

---

#### COMBINACIÓN 2: FUEGO + ESCUDO
**Nombre:** Estallido del Núcleo

**Estadísticas:**
- **Tipo:** AoE explosivo
- **Daño:** 8 puntos
- **Radio:** 3 unidades (circular, centrado en jugador)
- **Cooldown:** 16 segundos (ambas runas)
- **Costo Maná:** 14 puntos
- **Knockback:** 1.5 unidades (radial desde jugador)
- **Duración Animación:** 0.3 segundos

**Comportamiento:**
1. Explosión instantánea al confirmar:
   - Afecta TODOS los enemigos dentro del radio
   - Afecta TODOS los objetos destructibles
   - Empuja bloques empujables 1 unidad en dirección radial
2. Knockback a enemigos:
   - Empuja desde centro del jugador hacia afuera
   - Si enemigo choca con pared, se detiene
   - No causa daño adicional por colisión
3. Durante animación (0.3s):
   - Jugador NO puede moverse ni atacar
   - Jugador NO es invulnerable
4. No atraviesa paredes (los enemigos detrás de muros no se afectan)

**Casos Especiales:**
- Bloques empujables: Se mueven EXACTAMENTE 1 unidad en dirección radial, se detienen en la siguiente celda del grid
- Objetos destructibles: Se destruyen sin importar su vida restante

**VFX:**
- Carga (0.1s): Aura roja creciendo alrededor del jugador
- Explosión: Onda expansiva roja/naranja con distorsión de calor
- Persistente: Marcas de quemadura en el suelo (fade out en 2s)

**SFX:**
- Carga: Zumbido creciente
- Explosión: "BOOM" grave con reverb
- Impactos: Múltiples sonidos de impacto superpuestos

---

#### COMBINACIÓN 3: ESCUDO + MOVIMIENTO
**Nombre:** Onda Cinética

**Estadísticas:**
- **Tipo:** Empuje direccional (utilidad)
- **Daño:** 0 puntos
- **Fuerza de Empuje:** Empuje de 2 unidades
- **Alcance:** 4 unidades (en línea recta)
- **Ancho:** Cono de 45° desde punto de origen
- **Cooldown:** 18 segundos (ambas runas)
- **Costo Maná:** 12 puntos
- **Duración Aturdimiento:** 0.8 segundos
- **Velocidad de Onda:** Instantáneo (efecto inmediato en área)

**Comportamiento:**
1. Dirección (misma prioridad que Dardo Ígneo):
   - Hacia mouse > última dirección > arriba por defecto
2. Efectos por tipo de objeto:
   - **Enemigos:**
	 - Empujados 2 unidades en dirección del empuje
	 - Aturdidos (no pueden moverse ni atacar) 0.8s
	 - Interrumpe animaciones de ataque
	 - Si chocan con pared/obstáculo, se detienen inmediatamente
   - **Bloques Empujables:**
	 - Se mueven EXACTAMENTE 1 celda del grid en dirección del empuje
	 - Si la celda destino está ocupada, NO se mueven
	 - Solo afecta bloques que estén directamente alineados (no en diagonal)
   - **Objetos Destructibles:**
	 - NO se destruyen (solo se empujan si es posible)
3. Múltiples objetos:
   - Pueden ser afectados simultáneamente si están en el área
4. NO atraviesa paredes (el cono se corta al encontrar obstáculo)

**Interacciones con Puzzles:**
- Ideal para resolver puzzles de bloques empujables
- Puede empujar múltiples bloques a la vez si están alineados
- Útil para crear espacio entre jugador y enemigos

**VFX:**
- Carga (0.1s): Espiral azul/blanca girando frente al jugador
- Onda: Cono semitransparente con distorsión tipo "fuerza"
- Impacto en objetos: Anillos de energía expandiéndose
- Aturdimiento: Estrellas girando sobre cabeza del enemigo

**SFX:**
- Carga: Zumbido agudo
- Onda: "Whomp" profundo con eco
- Impacto: Sonido de viento fuerte + impacto sordo

---

### 3.5 Sistema de Cooldowns

**Reglas:**

1. **Runas Individuales:**
   - Cada runa tiene su propio cooldown independiente
   - Usar Fuego no afecta cooldowns de Escudo o Movimiento

2. **Combinaciones:**
   - Al usar una combinación, AMBAS runas entran en cooldown
   - Ejemplo: Usar Dardo Ígneo (F+M):
	 - Fuego: 12s de cooldown
	 - Movimiento: 12s de cooldown
   - Los cooldowns de las combinaciones siempre son más largos que los individuales

3. **Cooldowns Activos Simultáneos:**
   - Se pueden tener múltiples cooldowns activos
   - Ejemplo: Usar Fuego individual (10s) y luego Escudo individual (14s):
	 - Mientras esperas el Escudo, puedes usar Movimiento

**Tabla de Cooldowns:**

| Habilidad | Cooldown | Runas Afectadas |
|-----------|----------|-----------------|
| Fuego individual | 10s | Solo Fuego |
| Movimiento individual | 8s | Solo Movimiento |
| Escudo individual | 14s | Solo Escudo |
| Dardo Ígneo (F+M) | 12s | Fuego Y Movimiento |
| Estallido (F+E) | 16s | Fuego Y Escudo |
| Onda Cinética (E+M) | 18s | Escudo Y Movimiento |

**Visualización en UI:**
- Barra circular alrededor del ícono de runa (tipo "reloj")
- Color: Gris oscuro durante cooldown → Verde cuando disponible
- Texto numérico centrado: "8.3s" (actualiza cada 0.1s)
- Al estar disponible: Brillo suave + pulso del ícono

---

## 4. ENEMIGOS Y COMBATE

### 4.1 Enemigo Básico: "Sombra Corrupta"

**Estadísticas:**
- **Vida:** 10 HP
- **Daño:** 2 HP por golpe
- **Velocidad:** 3 unidades/segundo (75% de la velocidad del jugador)
- **Radio de Detección:** 8 unidades
- **Radio de Ataque:** 1.5 unidades
- **Cooldown de Ataque:** 2 segundos

**Inteligencia Artificial (FSM):**

1. **PATROL (Patrullaje):**
   - Comportamiento: Camina entre 2-3 waypoints predefinidos
   - Velocidad: 1.5 unidades/segundo (50% velocidad normal)
   - Transición: Si jugador entra en radio de detección → CHASE

2. **CHASE (Persecución):**
   - Comportamiento: Se mueve en línea recta hacia el jugador
   - Velocidad: 3 unidades/segundo (velocidad normal)
   - Pathfinding: Directo, no rodea obstáculos (se atora en paredes)
   - Transición:
	 - Si jugador sale del radio de detección (8u) por 3 segundos → RETURN
	 - Si jugador entra en radio de ataque → ATTACK

3. **ATTACK (Ataque):**
   - Comportamiento:
	 - Se detiene (velocidad = 0)
	 - Animación de ataque (0.5s): Levanta brazos
	 - Golpe (0.2s): Inflige daño si jugador sigue en rango
	 - Cooldown (2s): Espera antes de siguiente ataque
   - Transición:
	 - Si jugador sale del radio de ataque → CHASE
	 - Si recibe aturdimiento (Onda Cinética) → STUNNED

4. **STUNNED (Aturdido):**
   - Comportamiento: Inmóvil, no ataca, no persigue
   - Duración: 0.8 segundos
   - Visual: Sprite con estrellas girando encima
   - Transición: Después de duración → CHASE

5. **RETURN (Regresar):**
   - Comportamiento: Vuelve al waypoint más cercano
   - Velocidad: 2 unidades/segundo
   - Transición:
	 - Al llegar al waypoint → PATROL
	 - Si jugador entra en radio de detección → CHASE

**Comportamientos Especiales:**
- Si recibe knockback: Mantiene estado actual, solo se desplaza
- Si recibe quemadura: Sigue su comportamiento normal, recibe DoT
- Si está contra una pared: Intenta moverse en diagonal para rodearlo (50% del tiempo lo logra)

**Recompensas al Morir:**
- Ninguna (post-MVP: orbes de maná)

**Variantes para Salas (mismo enemigo, diferentes configuraciones):**
- Sala 1: 2 enemigos, waypoints separados
- Sala 2: 3 enemigos, waypoints en patrón triangular
- Sala 3: 4 enemigos, 2 patrullando + 2 estáticos (sin patrullar, solo atacan si jugador se acerca)

---

### 4.2 Jefe Final: "Guardián del Núcleo Corrupto"

**Estadísticas:**
- **Vida:** 60 HP
- **Velocidad:** 2.5 unidades/segundo
- **Fases:** 2 (cambia al 50% de vida, 30 HP)

**Arena:**
- Sala circular de 15 unidades de diámetro
- 4 pilares destructibles en los puntos cardinales (10 HP cada uno)
- Centro: Cristal decorativo (invulnerable)

---

#### FASE 1: Guardián Defensivo (60-31 HP)

**Patrón 1: Embestida Cargada (Charge)**
- **Frecuencia:** Cada 8 segundos
- **Comportamiento:**
  1. Preparación (1s): Se detiene, sprite brilla rojo, mira hacia jugador
  2. Ejecución: Dash en línea recta hacia la posición del jugador (no tracking)
	 - Velocidad: 12 unidades/segundo
	 - Distancia: Hasta golpear pared/pilar o 10 unidades
  3. Si golpea pilar: Destruye el pilar + se aturde 1 segundo
  4. Si golpea jugador: 4 HP de daño + knockback de 2 unidades
  5. Recuperación (0.5s): Se detiene, sacude cabeza
- **Contraataque:** Esquivar con Destello o esconderse detrás de pilar

**Patrón 2: Golpe Circular (Slam)**
- **Frecuencia:** Cada 5 segundos (intercalado con Charge)
- **Comportamiento:**
  1. Preparación (0.8s): Levanta arma/brazos, aura púrpura
  2. Ejecución: Golpe AoE circular
	 - Radio: 3 unidades (centrado en jefe)
	 - Daño: 3 HP
	 - Knockback: 1.5 unidades (radial)
  3. Recuperación (0.5s): Vulnerable, no se mueve
- **Contraataque:** Alejarse más de 3 unidades o usar Destello para esquivar

**Movimiento entre Patrones:**
- Persigue al jugador a 2.5 unidades/segundo
- Se detiene al iniciar cualquier patrón

---

#### FASE 2: Guardián Agresivo (30-0 HP)

**Trigger:** Al llegar a 30 HP
- Animación de transición (2s): Aullido, aura roja explosiva, invulnerable durante animación
- Velocidad aumenta a 3.5 unidades/segundo

**Patrón 1: Embestida Doble (Double Charge)**
- **Frecuencia:** Cada 7 segundos
- **Comportamiento:**
  1. Primera embestida (igual que Fase 1)
  2. Sin recuperación: Inmediatamente prepara segunda embestida (0.5s)
  3. Segunda embestida hacia nueva posición del jugador
  4. Recuperación (0.8s) solo después de la segunda
- **Contraataque:** Dos Destellos seguidos o posicionamiento estratégico

**Patrón 2: Golpe Circular + Onda de Choque (Slam + Shockwave)**
- **Frecuencia:** Cada 6 segundos
- **Comportamiento:**
  1. Slam (igual que Fase 1): 3 unidades, 3 HP
  2. Inmediatamente después: Onda de choque secundaria
	 - Radio: 5 unidades (más grande que el slam)
	 - Daño: 2 HP
	 - No tiene knockback
	 - Delay: 0.5s después del slam
  3. Recuperación (0.3s): Menos tiempo vulnerable
- **Contraataque:** Destello hacia afuera después del primer impacto, o Escudo para absorber ambos golpes

**Patrón 3: Proyectiles de Sombra (NUEVO)**
- **Frecuencia:** Cada 10 segundos
- **Comportamiento:**
  1. Preparación (1s): Se detiene, tres orbes negros orbitan alrededor del jefe
  2. Disparo: Lanza los 3 proyectiles secuencialmente (0.2s entre cada uno) hacia el jugador
	 - Velocidad: 6 unidades/segundo
	 - Daño: 2 HP cada uno
	 - Tracking: Apuntan hacia posición del jugador al momento del disparo
	 - Desaparecen al golpear jugador/pared o después de 8 unidades
  3. Recuperación (0.5s)
- **Contraataque:** Movimiento errático o Destello para esquivar, Escudo para bloquear

**Prioridad de Patrones en Fase 2:**
- Double Charge → Slam + Shockwave → Proyectiles → Repetir
- Si el jugador está muy cerca (<2 unidades): Prioriza Slam
- Si el jugador está lejos (>6 unidades): Prioriza Proyectiles

---

**Estrategia Recomendada para Derrotar al Jefe:**

Fase 1:
1. Usar pilares como escudos contra Charge
2. Atacar durante las recuperaciones (0.5s después de cada patrón)
3. Dardo Ígneo desde distancia segura
4. Escudo para tanquear Slam si es necesario

Fase 2:
1. Mantenerse en movimiento constante
2. Usar Destello para esquivar Double Charge
3. Estallido del Núcleo cuando el jefe esté cerca + múltiples Sombras Corruptas
4. Gestionar maná cuidadosamente (regenera 2/s)

**Nota de Diseño:** El jefe debe sentirse como un "examen final" que requiere dominar las 3 runas + sus combinaciones.

---

## 5. DISEÑO DE NIVELES

### 5.1 Estructura General

**Progresión Lineal:**
```
Tutorial → Sala 1 (Bosque) → Sala 2 (Ruinas) → Sala 3 (Caverna) → Sala Jefe
```

**Tamaño Estándar de Salas:**
- Ancho: 20 unidades (640 píxeles @ 32px/unidad)
- Alto: 15 unidades (480 píxeles)
- Viewport: Cámara fija centrada en la sala (no sigue al jugador entre salas)

**Transiciones:**
- Puertas en los bordes de cada sala
- Al tocar puerta: Fade out (0.3s) → Cambio de sala → Fade in (0.3s)
- Jugador aparece en el lado opuesto de la nueva sala

---

### 5.2 Tutorial (Sala 0)

**Objetivo de Diseño:** Enseñar mecánicas core en 3-5 minutos

**Layout:**
```
[Entrada]
	↓
[Sección 1: Movimiento] → Cartel: "WASD para moverte"
	↓
[Sección 2: Ataque] → Dummy invulnerable + Cartel: "CLICK IZQ / J para atacar"
	↓
[Sección 3: Runas] → 3 Carteles:
	- "F: Runa de Fuego (+Daño)"
	- "M: Destello (Dash)"
	- "E: Escudo (Protección)"
	↓
[Sección 4: Combinación] → Cartel: "Presiona F, luego M, luego ESPACIO"
	→ Dummy con 6 HP (justo lo necesario para 1 Dardo Ígneo)
	↓
[Salida] → Puerta a Sala 1
```

**Elementos:**
- 2 Dummies (maniquíes de entrenamiento):
  - Dummy 1: Invulnerable (para practicar ataque básico)
  - Dummy 2: 6 HP, vulnerable (para practicar Dardo Ígneo)
- 4 Carteles de texto
- Obstáculos simples (rocas) para practicar navegación

**Tiempo Estimado:** 3-5 minutos

---

### 5.3 Sala 1: Bosque de las Sombras

**Objetivo de Diseño:** Primer combate real + introducción a enemigos

**Tema Visual:** Bosque denso, árboles retorcidos, niebla ligera

**Layout:**
```
		[Entrada desde Tutorial]
				↓
	[Área Segura - 3x3 unidades]
				↓
	[Zona de Combate Principal]
	- 2 Sombras Corruptas patrullando
	- Árboles como obstáculos (bloqueadores de visión)
				↓
		[Cofre opcional]
	(Recupera 15 de maná)
				↓
		[Salida a Sala 2]
```

**Elementos:**
- 2 Sombras Corruptas (10 HP cada una)
- 8 Árboles gruesos (obstáculos sólidos, no destructibles)
- 3 Arbustos (obstáculos bajos, bloquean movimiento pero no visión)
- 1 Cofre (restaura 15 maná al abrirlo)

**Desafío Principal:**
- Aprender a gestionar cooldowns
- Entender el patrullaje y persecución de enemigos
- Primera experiencia con combate real

**Estrategia Recomendada:**
1. Observar patrones de patrullaje
2. Aislar y eliminar enemigos uno por uno
3. Usar árboles como cobertura
4. Practicar combo Fuego (buff) + Ataque básico

**Tiempo Estimado:** 8-10 minutos

---

### 5.4 Sala 2: Ruinas Antiguas

**Objetivo de Diseño:** Introducir puzzles con bloques empujables

**Tema Visual:** Ruinas de piedra, columnas caídas, musgo

**Layout:**
```
	[Entrada desde Sala 1]
			↓
	[Puzzle de Bloques]
	┌─────────────┐
	│ □ □ □       │  □ = Bloque empujable
	│   ☼         │  ☼ = Interruptor de presión
	│ □ E □       │  E = Enemigo estático
	│             │  P = Placa de presión (objetivo)
	│      P      │
	└─────────────┘
			↓
	[Puerta Desbloqueada]
			↓
	[Zona de Combate]
	- 3 Sombras Corruptas
			↓
	[Salida a Sala 3]
```

**Puzzle:**
- Objetivo: Empujar 1 bloque sobre la placa de presión para abrir puerta
- Solución: Usar Onda Cinética (E+M) para empujar bloque a distancia
- Alternativa: Empujar manualmente (el jugador puede empujar bloques caminando contra ellos)
- 1 Sombra Corrupta estática entre los bloques (debe ser evitada o eliminada)

**Elementos:**
- 5 Bloques empujables (1x1 unidad, 5 HP cada uno, destructibles con ataques)
- 1 Placa de presión (activa puerta al tener bloque encima)
- 1 Puerta (inicialmente cerrada)
- 3 Sombras Corruptas en la zona post-puerta
- 4 Columnas decorativas (obstáculos sólidos)

**Desafío Principal:**
- Aprender mecánica de empuje (Onda Cinética)
- Resolver puzzle bajo presión (enemigo cerca)
- Combate con múltiples enemigos simultáneos

**Estrategia Recomendada:**
1. Eliminar o esquivar enemigo estático del puzzle
2. Usar Onda Cinética para mover bloque
3. Abrir puerta
4. Enfrentar 3 enemigos usando Estallido del Núcleo para daño AoE

**Tiempo Estimado:** 10-12 minutos

---

### 5.5 Sala 3: Caverna Profunda

**Objetivo de Diseño:** Desafío de combate intenso + puzzle avanzado

**Tema Visual:** Caverna oscura, cristales brillantes, estalagmitas

**Layout:**
```
		[Entrada desde Sala 2]
				↓
		[Pasillo Estrecho]
	(2 Sombras patrullando)
				↓
	[Cámara de Cristales - Puzzle]
	┌─────────────────┐
	│  ◊   ◊   ◊      │  ◊ = Cristal destructible (3 HP)
	│    □   □        │  □ = Bloque
	│  E   ☼   E      │  ☼ = Interruptor central
	│    □   □        │  E = Enemigo
	│  ◊   ◊   ◊      │  
	└─────────────────┘
				↓
		[Arena de Combate]
	- 4 Sombras Corruptas
	- Espacio abierto
				↓
		[Checkpoint]
	(Restaura vida completa)
				↓
		[Salida a Sala Jefe]
```

**Puzzle de Cristales:**
- Objetivo: Destruir los 6 cristales para desbloquear interruptor central
- Cristales: 3 HP cada uno, vulnerables a cualquier ataque
- Solución óptima: Usar Estallido del Núcleo (destruye múltiples cristales a la vez)
- 2 Sombras Corruptas patrullan entre los cristales
- Al activar interruptor: Se abre paso al área de combate

**Elementos:**
- 6 Cristales destructibles (3 HP cada uno)
- 1 Interruptor central (requiere que todos los cristales estén destruidos)
- 4 Bloques empujables (decorativos, pueden usarse como cobertura)
- 2+4 = 6 Sombras Corruptas total
- 1 Checkpoint (piedra brillante que restaura 20 HP al tocarla, uso único)
- Estalagmitas (obstáculos decorativos)

**Desafío Principal:**
- Puzzle bajo presión de combate constante
- Mayor número de enemigos simultáneos
- Gestión de recursos (maná/vida) antes del jefe

**Estrategia Recomendada:**
1. Eliminar enemigos del pasillo usando el terreno estrecho
2. En puzzle: Usar Estallido para destruir cristales + dañar enemigos
3. Conservar algo de maná para el combate final
4. Usar checkpoint solo si es necesario (considera guardarlo si tienes >15 HP)

**Tiempo Estimado:** 12-15 minutos

---

### 5.6 Sala del Jefe: Núcleo Corrupto

**Objetivo de Diseño:** Confrontación final, prueba de todas las mecánicas

**Tema Visual:** Cámara circular masiva, cristal corrupto central, energía púrpura

**Layout:**
```
		[Entrada desde Sala 3]
				↓
	[Plataforma de Inicio]
	(Safe zone, 3 segundos antes de que jefe active)
				↓
		[Arena Circular]
	
		 P           P
			\     /
			  \ /
		───────◉───────  ◉ = Jefe (centro)
			  / \        P = Pilar (10 HP)
			/     \
		 P           P
	
	Radio: 7.5 unidades
	4 Pilares destructibles en puntos cardinales
	Cristal central (decorativo, invulnerable)
```

**Elementos:**
- 1 Guardián del Núcleo Corrupto (60 HP)
- 4 Pilares destructibles (10 HP cada uno, 1x1 unidad)
- 1 Cristal central (decorativo, invulnerable, 2x2 unidades)
- Arena circular sin salidas hasta derrotar al jefe

**Fases del Encuentro:**
- Fase 1: 60-31 HP (Defensivo)
- Transición: Animación de 2s al llegar a 30 HP
- Fase 2: 30-0 HP (Agresivo)

**Comportamiento Especial:**
- Al entrar: Cinemática corta (3 segundos):
  - Cámara enfoca al cristal central
  - Jefe emerge desde el suelo
  - Texto: "Guardián del Núcleo Corrupto"
  - Jugador no puede moverse durante cinemática
- Durante pelea: Puerta de entrada sellada
- Al derrotar: Puerta se desbloquea → Cristal central se purifica (VFX) → Pantalla de victoria

**Desafío Principal:**
- Examen final de todas las mecánicas
- Gestión avanzada de recursos
- Adaptación entre fases
- Uso estratégico del entorno (pilares)

**Estrategia Recomendada:**
Ver sección 4.2 (descripción del jefe)

**Tiempo Estimado:** 15-20 minutos (incluyendo reintentos)

---

### 5.7 Mapa de Conexiones

```
	┌─────────────┐
	│  TUTORIAL   │
	│   (Sala 0)  │
	└──────┬──────┘
		   │
	┌──────▼──────┐
	│   BOSQUE    │
	│   (Sala 1)  │
	└──────┬──────┘
		   │
	┌──────▼──────┐
	│   RUINAS    │
	│   (Sala 2)  │
	└──────┬──────┘
		   │
	┌──────▼──────┐
	│  CAVERNA    │
	│   (Sala 3)  │
	└──────┬──────┘
		   │
	┌──────▼──────┐
	│  SALA JEFE  │
	│   (Final)   │
	└─────────────┘
```

**Notas de Diseño:**
- Progresión lineal (sin backtracking)
- Cada sala introduce/refuerza 1 mecánica nueva
- Dificultad escalonada
- Sala 3 sirve como preparación directa para jefe (checkpoint estratégico)

---

## 6. INTERFAZ DE USUARIO (UI)

### 6.1 HUD (Heads-Up Display) - In-Game

**Layout General:**
```
┌────────────────────────────────────┐
│ [❤❤❤❤❤] 20/20 HP       F  E  M │  ← Top bar
│ [████████] 50/50 MP     [8][14][8] │
│                                    │
│                                    │
│         [GAMEPLAY AREA]            │
│                                    │
│                                    │
│                                    │
└────────────────────────────────────┘
```

**Elementos del HUD:**

1. **Barra de Vida (Top-Left):**
   - Posición: Esquina superior izquierda (10px margin)
   - Tamaño: 200px ancho x 30px alto
   - Diseño:
	 - Corazones visuales: 5 corazones, cada uno = 4 HP
	 - Color: Rojo (#FF0000) cuando lleno, Gris oscuro (#333333) cuando vacío
	 - Texto: "20/20 HP" alineado a la derecha de los corazones
	 - Animación: Parpadeo rojo al recibir daño + sacudida de 2px

2. **Barra de Maná (Below HP):**
   - Posición: Debajo de barra de vida (5px gap)
   - Tamaño: 200px ancho x 20px alto
   - Diseño:
	 - Barra líquida azul (#00AAFF) con gradiente
	 - Borde: 2px negro
	 - Texto: "50/50 MP" centrado sobre la barra
	 - Animación: Onda suave al regenerarse (efecto "agua")

3. **Iconos de Runas (Top-Right):**
   - Posición: Esquina superior derecha (10px margin)
   - Tamaño: 3 iconos de 48x48px cada uno, espaciados 10px
   - Layout:
	 ```
	 [F]  [E]  [M]
	 [8s][14s][8s]
	 ```
   - Estados:
	 - **Disponible:** Color completo + brillo suave
	 - **Seleccionada:** Borde dorado (4px) + escala 110%
	 - **En cooldown:** Gris + overlay circular que se vacía (tipo reloj)
	 - **Sin maná:** Gris + icono de maná tachado
   - Cooldown Timer:
	 - Texto blanco con sombra negra
	 - Tamaño: 14px font
	 - Actualiza cada 0.1s
	 - Formato: "12.3s" o "0.8s"

4. **Indicador de Combinación (Center-Top, temporal):**
   - Aparece solo cuando hay 2 runas seleccionadas
   - Posición: Centro superior (debajo del borde, 50px desde top)
   - Diseño:
	 - Texto: "ESPACIO para [Nombre de Combo]"
	 - Fondo: Semi-transparente negro (80% opacity)
	 - Tamaño: 300px ancho x 40px alto
	 - Animación: Fade in (0.2s) al aparecer
   - Ejemplo: "ESPACIO para Dardo Ígneo"

---

### 6.2 Menú Principal

**Layout:**
```
╔════════════════════════════════╗
║                                ║
║      RUNAS DEL NÚCLEO          ║
║                                ║
║      [  INICIAR JUEGO  ]       ║
║      [    CONTROLES    ]       ║
║      [     CRÉDITOS    ]       ║
║      [      SALIR      ]       ║
║                                ║
║                                ║
╚════════════════════════════════╝
```

**Elementos:**
- Fondo: Imagen del bosque con overlay oscuro (60% opacity)
- Título: Fuente grande (72px), color dorado con borde negro
- Botones:
  - Tamaño: 300px ancho x 50px alto
  - Color normal: Gris oscuro con borde blanco
  - Hover: Dorado con brillo
  - Click: Escala 95% + sonido
- Música de fondo: Loop ambiental suave

**Navegación:**
- Mouse: Hover + click
- Teclado: W/S para navegar, Enter para seleccionar, ESC para volver

---

### 6.3 Pantalla de Controles

```
╔════════════════════════════════╗
║         CONTROLES              ║
║                                ║
║  MOVIMIENTO:                   ║
║    W A S D - Mover jugador     ║
║                                ║
║  COMBATE:                      ║
║    Click Izq / J - Ataque      ║
║                                ║
║  RUNAS:                        ║
║    F - Runa de Fuego           ║
║    E - Runa de Escudo          ║
║    M - Runa de Movimiento      ║
║    ESPACIO - Confirmar combo   ║
║    TAB - Cancelar selección    ║
║                                ║
║      [    VOLVER    ]          ║
╚════════════════════════════════╝
```

---

### 6.4 Pantalla de Pausa (In-Game)

**Trigger:** Presionar ESC durante gameplay

```
╔════════════════════════════════╗
║           PAUSA                ║
║                                ║
║      [   CONTINUAR   ]         ║
║      [   CONTROLES   ]         ║
║      [  MENÚ PRINCIPAL ]       ║
║                                ║
║  (El juego se oscurece 70%)    ║
╚════════════════════════════════╝
```

**Comportamiento:**
- Gameplay congelado (tiempo se detiene)
- Enemigos no se mueven
- Cooldowns se pausan
- Música se atenúa a 30% volumen

---

### 6.5 Pantalla de Muerte

```
╔════════════════════════════════╗
║                                ║
║       HAS SIDO DERROTADO       ║
║                                ║
║    Enemigo: [Nombre]           ║
║    Tiempo: [12:34]             ║
║                                ║
║      [ REINTENTAR SALA ]       ║
║      [  MENÚ PRINCIPAL ]       ║
║                                ║
╚════════════════════════════════╝
```

**Comportamiento:**
- Fade out rojo (1s) desde el juego
- Muestra estadísticas básicas
- Reintentar: Vuelve al inicio de la sala actual con vida/maná completos
- No hay penalización (más allá de tiempo perdido)

---

### 6.6 Pantalla de Victoria

```
╔════════════════════════════════╗
║                                ║
║      ¡NÚCLEO PURIFICADO!       ║
║                                ║
║    Tiempo Total: 42:18         ║
║    Daño Recibido: 35 HP        ║
║    Runas Usadas: 47            ║
║                                ║
║  "El bosque respira de nuevo"  ║
║                                ║
║      [  MENÚ PRINCIPAL ]       ║
║                                ║
╚════════════════════════════════╝
```

**Comportamiento:**
- Fade in desde gameplay (2s)
- Cristal central se purifica (VFX)
- Música de victoria (30s)
- Muestra estadísticas del playthrough
- Créditos cortos (scroll automático después de 5s)

---

### 6.7 Carteles In-Game (Tutorial)

**Diseño:**
- Tamaño: 150px ancho x 100px alto
- Fondo: Pergamino envejecido
- Texto: Negro, fuente legible (16px)
- Posición: Sobre el cartel en el mundo (no UI overlay)
- Interacción: Se muestra automáticamente al acercarse (3 unidades)

**Ejemplos:**
```
┌──────────────┐
│  "WASD para  │
│   moverte"   │
└──────────────┘
```

---

## 7. ARTE Y VISUALES

### 7.1 Estilo Visual

**Dirección Artística:**
- Estilo: Pixel art, 32x32 píxeles por unidad
- Paleta: Oscura con acentos vibrantes
- Inspiración: Top-down 16-bit (SNES era)

**Paleta de Colores Principal:**
```
Bosque:
  - Verde oscuro (#1A3A2E)
  - Verde musgo (#4A7C59)
  - Marrón tierra (#6F4E37)

Ruinas:
  - Gris piedra (#7D7D7D)
  - Beige envejecido (#C9B199)
  - Musgo verde (#8FBC8F)

Caverna:
  - Negro azulado (#1C1C28)
  - Morado cristal (#9D4EDD)
  - Azul brillante (#00D9FF)

Jefe:
  - Púrpura corrupto (#6A0572)
  - Rojo oscuro (#8B0000)
  - Negro (#000000)
```

**Iluminación:**
- Estática (sin luz dinámica en MVP)
- Cada sala tiene "mood lighting" preestablecida
- Caverna: Zonas de penumbra con cristales brillantes
- Sala jefe: Iluminación púrpura intensa

---

### 7.2 Sprites del Jugador

**Tamaño:** 32x32 píxeles (1 unidad)

**Animaciones Necesarias:**

1. **Idle (Reposo):** 2 frames, loop de 1s
2. **Walk (Caminar):** 4 frames, 8 direcciones = 32 frames total
   - Alternativamente: 4 direcciones + flip horizontal = 16 frames
3. **Attack (Ataque):** 3 frames, 0.2s total
4. **Hurt (Daño):** 2 frames, flash rojo
5. **Dash (Destello):** 2 frames con motion blur

**Estados Visuales:**
- Normal: Sprite base
- Con Fuego activo: Aura naranja/roja alrededor + trail de partículas
- Con Escudo activo: Domo azul semitransparente (sprite separado overlay)
- En cooldown de Destello: Sin cambio visual (feedback solo en UI)

---

### 7.3 Sprites de Enemigos

**Sombra Corrupta:**
- Tamaño: 32x32 píxeles
- Diseño: Figura humanoide negra con ojos rojos brillantes
- Animaciones:
  - Idle: 2 frames, respiración suave
  - Walk: 4 frames
  - Attack: 3 frames, levanta brazos
  - Hurt: Flash blanco
  - Death: 4 frames, se disuelve en humo negro

**Guardián del Núcleo Corrupto (Jefe):**
- Tamaño: 64x64 píxeles (2x2 unidades)
- Diseño: Criatura masiva, cristales púrpuras incrustados, aura oscura
- Animaciones:
  - Idle: 4 frames, respiración pesada
  - Walk: 6 frames
  - Charge (Preparación): 3 frames, sprite brilla rojo
  - Charge (Ejecución): 2 frames, motion blur
  - Slam (Preparación): 4 frames, levanta brazos
  - Slam (Ejecución): 2 frames, impacto
  - Projectile Attack: 5 frames, genera orbes
  - Phase Transition: 8 frames, aullido + aura explosiva
  - Hurt: Flash blanco
  - Death: 10 frames, se desintegra + explosión de luz

---

### 7.4 Efectos Visuales (VFX)

**Partículas:**

1. **Fuego (Toque de Fuego):**
   - Tipo: Emisor continuo desde jugador
   - Color: Naranja → Rojo → Amarillo (gradiente)
   - Cantidad: 15 partículas/segundo
   - Velocidad: Ascendentes, 1 unidad/s
   - Vida: 0.5s
   - Tamaño: 4px → 2px (shrink)

2. **Destello (Trail):**
   - Tipo: Trail de movimiento
   - Color: Blanco → Azul claro (fade)
   - Cantidad: 20 partículas en línea
   - Velocidad: Estáticas (quedan en posición)
   - Vida: 0.3s
   - Tamaño: 8px → 0px

3. **Escudo (Campo de Fuerza):**
   - Tipo: Overlay circular animado
   - Color: Azul (#00AAFF) 50% opacity
   - Animación: Patrón hexagonal pulsante
   - Impacto: Ondas concéntricas desde punto de colisión
   - Rotura: 12 fragmentos dispersándose radialmente

4. **Dardo Ígneo:**
   - Proyectil: Esfera 16x16px con trail de 10 partículas
   - Color: Naranja brillante + amarillo en centro
   - Trail: Partículas de fuego (8 frames, fade out)
   - Impacto: Explosión de 20 partículas radiantes

5. **Estallido del Núcleo:**
   - Onda expansiva: Círculo que crece de 0 a 3 unidades en 0.3s
   - Color: Rojo → Naranja (gradiente radial)
   - Distorsión: Efecto de calor (warping shader si es posible)
   - Persistente: Marcas de quemadura en suelo (sprites estáticos, 2s)

6. **Onda Cinética:**
   - Cono: Sprite semitransparente con distorsión tipo "onda de choque"
   - Color: Azul claro (#ADD8E6) 60% opacity
   - Animación: Pulso que avanza 4 unidades en 0.1s
   - Impacto: Anillos de energía alrededor de objetos empujados

**Efectos de Pantalla:**

1. **Damage Vignette:** Bordes rojos al recibir daño (0.5s)
2. **Low Health:** Borde rojo pulsante cuando HP < 25%
3. **Fase Transición del Jefe:** Screen shake (5px, 0.5s) + flash blanco
4. **Victoria:** Fade to white (2s) + partículas doradas ascendentes

---

### 7.5 Tiles y Entorno

**Tileset por Sala:**

**Bosque:**
- Suelo: Pasto/tierra (2 variantes para variedad)
- Obstáculos: Árboles (3 variantes), rocas grandes, arbustos
- Decoración: Flores, hongos, troncos caídos

**Ruinas:**
- Suelo: Piedra agrietada (2 variantes)
- Obstáculos: Columnas, muros derruidos, bloques
- Decoración: Musgo, enredaderas, escombros

**Caverna:**
- Suelo: Roca oscura (2 variantes)
- Obstáculos: Estalagmitas, estalactitas, rocas
- Decoración: Cristales brillantes (3 colores), charcos

**Sala del Jefe:**
- Suelo: Piedra ritual con patrones (1 diseño único)
- Obstáculos: 4 pilares, cristal central
- Decoración: Runas grabadas en el suelo, grietas con energía

**Tamaño de Tiles:** 32x32 píxeles (1 unidad de juego)

---

## 8. AUDIO

### 8.1 Música

**Pistas Necesarias:**

1. **Menú Principal:** Ambiente etéreo, misterioso (loop 2 minutos)
2. **Tutorial:** Suave, educativo, no intimidante (loop 1.5 min)
3. **Bosque (Sala 1):** Tensión baja, exploración (loop 2 min)
4. **Ruinas (Sala 2):** Tensión media, percusión suave (loop 2 min)
5. **Caverna (Sala 3):** Tensión alta, ritmo acelerado (loop 2 min)
6. **Jefe - Fase 1:** Épico, orquestación, tensión constante (loop 1.5 min)
7. **Jefe - Fase 2:** Más rápido, urgente, peligro (loop 1.5 min)
8. **Victoria:** Triunfal, breve (30s, no loop)

**Estilo:** Orquestal/sintético híbrido, inspiración en Zelda/Hyper Light Drifter

**Volumen:**
- Música: -12dB default
- SFX: -6dB default
- Ajustables en configuración (post-MVP)

---

### 8.2 Efectos de Sonido (SFX)

**Jugador:**

1. **Movimiento:**
   - Pasos: 4 variantes, se alternan, 0.4s entre cada uno
   - Dash: Whoosh agudo + aterrizaje (thump suave)

2. **Combate:**
   - Ataque básico: Slash cortante (3 variantes)
   - Impacto en enemigo: Golpe sordo + grunt del enemigo
   - Impacto en objeto: Golpe más agudo

3. **Runas:**
   - Seleccionar runa: "Beep" suave
   - Confirmar combo: "Chime" armónico
   - Cancelar: "Whoosh" descendente
   
4. **Habilidades:**
   - Toque de Fuego: Whoosh + crepitar de fuego
   - Destello: Swoosh + thump
   - Campo de Fuerza: Zumbido eléctrico + shield ding
   - Dardo Ígneo: Fwoosh + silbido + boom al impactar
   - Estallido: Boom grave + reverb
   - Onda Cinética: Whomp + eco

5. **Daño/Muerte:**
   - Recibir daño: Grunt de dolor (3 variantes)
   - Muerte: Grito + caída

**Enemigos:**

1. **Sombra Corrupta:**
   - Detección: Gruñido bajo
   - Ataque: Slash + gruñido
   - Daño: Sonido etéreo (como vidrio)
   - Muerte: Disolución (whoosh descendente)

2. **Guardián del Núcleo:**
   - Spawn: Rugido profundo + temblor
   - Charge prep: Rugido creciente
   - Charge execution: Trueno
   - Slam: Impacto masivo + shockwave
   - Proyectiles: Zumbido energético + lanzamiento (3x)
   - Fase transition: Aullido + explosión energética
   - Muerte: Explosión + eco largo

**Ambiente:**

1. **Bosque:** Viento suave, pájaros distantes, hojas
2. **Ruinas:** Viento entre columnas, goteo de agua
3. **Caverna:** Eco, goteo constante, cristales resonando
4. **Sala Jefe:** Zumbido de energía corrupta, sin ambiente natural

**UI:**

1. **Menú:** Hover (tick suave), Click (confirmación clara), Back (whoosh)
2. **Cooldown completado:** Chime brillante
3. **Sin maná:** Sonido de error (buzz bajo)
4. **Cofre abierto:** Destello mágico + chime
5. **Checkpoint:** Resonancia curativa + brillo

**Formato de Audio:**
- Música: .ogg (compresión, loops perfectos)
- SFX: .wav (sin compresión, baja latencia)
- Sample rate: 44.1kHz
- Bit depth: 16-bit

---

## 9. ESPECIFICACIONES TÉCNICAS

### 9.1 Motor y Herramientas

**Motor Recomendado:** Godot Engine 4.x o Unity 2022 LTS

**Razones:**
- Godot: Open source, excelente para 2D, exportación web fácil
- Unity: Más recursos/tutoriales, mejor para portfolios

**Herramientas de Desarrollo:**

1. **Arte:**
   - Aseprite (pixel art y animaciones)
   - Tiled (mapas de tiles, exporta a JSON/XML)
   
2. **Audio:**
   - Audacity (edición SFX)
   - LMMS/FL Studio (música)
   - Bfxr/Chiptone (SFX procedurales)

3. **Diseño:**
   - Figma/Excalidraw (mockups UI)
   - Notion/Obsidian (documentación)

4. **Control de Versiones:**
   - Git + GitHub/GitLab
   - .gitignore configurado para binarios grandes

---

### 9.2 Arquitectura del Código

**Estructura de Carpetas:**
```
/RunasDelNucleo
├── /Assets
│   ├── /Sprites
│   │   ├── /Player
│   │   ├── /Enemies
│   │   ├── /Environment
│   │   └── /UI
│   ├── /Audio
│   │   ├── /Music
│   │   └── /SFX
│   ├── /Fonts
│   └── /Shaders (opcional)
├── /Scripts
│   ├── /Player
│   │   ├── PlayerController.cs
│   │   ├── PlayerStats.cs
│   │   └── PlayerAnimator.cs
│   ├── /Runes
│   │   ├── RuneSystem.cs
│   │   ├── RuneBase.cs
│   │   ├── FireRune.cs
│   │   ├── DashRune.cs
│   │   ├── ShieldRune.cs
│   │   └── Combinations/
│   ├── /Enemies
│   │   ├── EnemyBase.cs
│   │   ├── ShadowEnemy.cs
│   │   └── BossController.cs
│   ├── /Managers
│   │   ├── GameManager.cs
│   │   ├── AudioManager.cs
│   │   ├── UIManager.cs
│   │   └── SceneTransitionManager.cs
│   └── /Utils
│       ├── Cooldown.cs
│       └── HealthSystem.cs
├── /Scenes
│   ├── MainMenu.scene
│   ├── Tutorial.scene
│   ├── Room1_Forest.scene
│   ├── Room2_Ruins.scene
│   ├── Room3_Cave.scene
│   └── Room4_Boss.scene
└── /Prefabs
	├── Player.prefab
	├── ShadowEnemy.prefab
	├── Boss.prefab
	└── /Projectiles
```

---

### 9.3 Sistemas Core

#### Sistema de Runas (Pseudocódigo)

```
class RuneSystem:
	selectedRunes = []  // Array de runas seleccionadas (max 2)
	
	function SelectRune(runeType):
		if runeType is in cooldown:
			PlaySound("error")
			return
			
		if player.mana < runeType.manaCost:
			PlaySound("no_mana")
			return
			
		if selectedRunes.length == 0:
			selectedRunes.add(runeType)
			UpdateUI_Highlight(runeType)
			PlaySound("select")
			
		else if selectedRunes.length == 1:
			if selectedRunes[0] == runeType:
				// Misma runa, no hacer nada o ejecutar individual
				return
			else:
				selectedRunes.add(runeType)
				UpdateUI_ComboReady()
				PlaySound("combo_ready")
	
	function ConfirmAbility():
		if selectedRunes.length == 1:
			ExecuteIndividualRune(selectedRunes[0])
		else if selectedRunes.length == 2:
			ExecuteCombination(selectedRunes[0], selectedRunes[1])
		
		ClearSelection()
	
	function ExecuteCombination(rune1, rune2):
		comboKey = SortedPair(rune1, rune2)  // "Fire_Dash"
		
		switch comboKey:
			case "Fire_Dash":
				FireDart()
			case "Fire_Shield":
				CoreBurst()
			case "Shield_Dash":
				KineticWave()
		
		// Aplicar cooldowns a AMBAS runas
		rune1.StartCooldown()
		rune2.StartCooldown()
		
		// Consumir maná
		player.ConsumeMana(combo.manaCost)
	
	function CancelSelection():
		selectedRunes.clear()
		UpdateUI_ClearHighlight()
		PlaySound("cancel")
```

---

#### Sistema de Cooldown (Pseudocódigo)

```
class Cooldown:
	duration = 0
	remainingTime = 0
	isActive = false
	
	function Start(seconds):
		duration = seconds
		remainingTime = seconds
		isActive = true
	
	function Update(deltaTime):
		if isActive:
			remainingTime -= deltaTime
			
			if remainingTime <= 0:
				remainingTime = 0
				isActive = false
				OnCooldownComplete()
	
	function IsReady():
		return !isActive
	
	function GetProgress():
		return 1 - (remainingTime / duration)  // 0 a 1
	
	function OnCooldownComplete():
		PlaySound("cooldown_ready")
		UpdateUI_RuneAvailable()
```

---

#### Sistema de Salud (Pseudocódigo)

```
class HealthSystem:
	maxHealth = 20
	currentHealth = 20
	isInvulnerable = false
	invulnerabilityTimer = 0
	
	function TakeDamage(amount):
		if isInvulnerable:
			return
		
		currentHealth -= amount
		currentHealth = Clamp(currentHealth, 0, maxHealth)
		
		UpdateUI_Health()
		PlaySound("player_hurt")
		StartInvulnerability(1.0)  // 1 segundo
		
		if currentHealth <= 0:
			Die()
	
	function StartInvulnerability(duration):
		isInvulnerable = true
		invulnerabilityTimer = duration
		StartFlashAnimation()  // 4 flashes
	
	function Update(deltaTime):
		if isInvulnerable:
			invulnerabilityTimer -= deltaTime
			
			if invulnerabilityTimer <= 0:
				isInvulnerable = false
				StopFlashAnimation()
	
	function Heal(amount):
		currentHealth += amount
		currentHealth = Clamp(currentHealth, 0, maxHealth)
		UpdateUI_Health()
		PlaySound("heal")
	
	function Die():
		PlaySound("player_death")
		PlayAnimation("death")
		Wait(1.5)  // Esperar animación
		ShowDeathScreen()
```

---

#### Sistema de Maná (Pseudocódigo)

```
class ManaSystem:
	maxMana = 50
	currentMana = 50
	regenRate = 2  // puntos por segundo
	regenDelay = 1  // segundos después del último uso
	timeSinceLastUse = 999
	
	function ConsumeMana(amount):
		if currentMana < amount:
			return false
		
		currentMana -= amount
		timeSinceLastUse = 0
		UpdateUI_Mana()
		return true
	
	function Update(deltaTime):
		timeSinceLastUse += deltaTime
		
		// Comenzar regeneración después del delay
		if timeSinceLastUse >= regenDelay:
			Regenerate(regenRate * deltaTime)
	
	function Regenerate(amount):
		if currentMana < maxMana:
			currentMana += amount
			currentMana = Clamp(currentMana, 0, maxMana)
			UpdateUI_Mana()
	
	function HasEnoughMana(amount):
		return currentMana >= amount
```

---

#### IA del Enemigo Básico (FSM Pseudocódigo)

```
enum EnemyState:
	PATROL
	CHASE
	ATTACK
	STUNNED
	RETURN

class ShadowEnemy:
	currentState = PATROL
	detectionRadius = 8
	attackRadius = 1.5
	patrolSpeed = 1.5
	chaseSpeed = 3.0
	attackCooldown = 2.0
	currentWaypoint = 0
	waypoints = []  // Definidos en editor
	
	function Update(deltaTime):
		distanceToPlayer = Distance(self, player)
		
		switch currentState:
			case PATROL:
				Patrol(deltaTime)
				if distanceToPlayer <= detectionRadius:
					TransitionTo(CHASE)
					
			case CHASE:
				ChasePlayer(deltaTime)
				if distanceToPlayer > detectionRadius + 2:  // Hysteresis
					losePlayerTimer += deltaTime
					if losePlayerTimer > 3:
						TransitionTo(RETURN)
				else:
					losePlayerTimer = 0
				
				if distanceToPlayer <= attackRadius:
					TransitionTo(ATTACK)
					
			case ATTACK:
				AttackPlayer(deltaTime)
				if distanceToPlayer > attackRadius:
					TransitionTo(CHASE)
					
			case STUNNED:
				stunTimer -= deltaTime
				if stunTimer <= 0:
					TransitionTo(CHASE)
					
			case RETURN:
				ReturnToWaypoint(deltaTime)
				if ReachedWaypoint():
					TransitionTo(PATROL)
				if distanceToPlayer <= detectionRadius:
					TransitionTo(CHASE)
	
	function Patrol(deltaTime):
		MoveTowards(waypoints[currentWaypoint], patrolSpeed * deltaTime)
		
		if ReachedWaypoint():
			currentWaypoint = (currentWaypoint + 1) % waypoints.length
	
	function ChasePlayer(deltaTime):
		direction = Normalize(player.position - self.position)
		Move(direction * chaseSpeed * deltaTime)
	
	function AttackPlayer(deltaTime):
		if attackCooldown.IsReady():
			PlayAnimation("attack")
			Wait(0.5)  // Windup
			
			if DistanceToPlayer() <= attackRadius:  // Check again
				player.TakeDamage(2)
			
			attackCooldown.Start(2.0)
	
	function OnStunned(duration):
		TransitionTo(STUNNED)
		stunTimer = duration
		PlayAnimation("stunned")
```

---

### 9.4 Optimización y Performance

**Targets de Performance:**
- **FPS:** 60 constantes
- **Resolución:** 1280x720 nativa, escalable a 1920x1080
- **Memoria:** <500MB RAM
- **Carga de sala:** <1 segundo

**Técnicas:**

1. **Object Pooling:**
   - Pool de proyectiles (pre-instanciar 10)
   - Pool de partículas (reusar emisores)
   - Pool de enemigos si es necesario

2. **Culling:**
   - No renderizar enemigos fuera de cámara
   - Desactivar AI de enemigos fuera de rango (12 unidades)

3. **Batching:**
   - Atlas de sprites (todas las texturas en 1-2 archivos)
   - Mismo material para objetos similares

4. **Audio:**
   - Máximo 8 sonidos simultáneos
   - Streams para música, samples para SFX

5. **Colisiones:**
   - Usar círculos/cajas simples (no polígonos complejos)
   - Spatial partitioning si >10 entidades por sala

---

### 9.5 Build y Deployment

**Configuraciones de Build:**

1. **Windows (Standalone):**
   - Ejecutable .exe
   - Carpeta con assets
   - Compresión: ZIP
   - Tamaño objetivo: <100MB

2. **WebGL:**
   - Build optimizado
   - Compresión Brotli/Gzip
   - Tamaño objetivo: <50MB
   - Hosting: Itch.io o GitHub Pages

**Checklist Pre-Release:**
- [ ] Todas las salas son completables
- [ ] Sin errores en consola
- [ ] Audio funciona en todas las plataformas
- [ ] Controles responden correctamente
- [ ] UI legible en resoluciones mínimas (1280x720)
- [ ] Framerate estable (60 FPS en hardware moderno)
- [ ] Playtesting por al menos 5 personas externas
- [ ] Tutoriales claros (100% comprensión en tests)

---

## 10. NARRATIVA

### 10.1 Contexto del Mundo

**Premisa:**
El Núcleo del Bosque, una fuente ancestral de magia natural, ha sido corrompido por una fuerza desconocida. El bosque se marchita, las criaturas se vuelven sombras agresivas, y la vida se extingue.

**Protagonista:**
Un/una guardián/a novato/a de las runas, entrenado/a para usar magia elemental básica. Es enviado/a como último recurso para purificar el Núcleo.

**Antagonista:**
El Guardián del Núcleo Corrupto - Una antigua criatura protectora que fue corrompida por la misma fuerza que infectó al Núcleo. No es malvada por naturaleza, sino que está siendo controlada.

---

### 10.2 Narrativa Integrada

**Pantalla de Inicio (Texto):**
```
"El Núcleo late con oscuridad.
El bosque agoniza.
Como último guardián entrenado,
debes purificar lo que fue corrompido.

Tus runas son jóvenes,
pero tu determinación es fuerte.

Entra al Bosque de las Sombras..."
```

**Durante Tutorial:**
- Cartel 1: "Bienvenido, guardián. Estas ruinas fueron nuestro hogar de entrenamiento..."
- Cartel final: "El bosque te llama. Recuerda: las combinaciones son más poderosas que las runas solas."

**Entrada a Sala del Jefe (Texto en pantalla):**
```
"El Núcleo pulsa ante ti.
El guardián corrupto despierta.
No hay vuelta atrás."
```

**Victoria (Texto final):**
```
"La luz regresa al cristal.
El guardián descansa al fin.
El bosque respira de nuevo.

Has probado tu valor.
Que las runas te guíen siempre."
```

**Total de Texto:** <150 palabras (narrativa minimalista como se prometió)

---

### 10.3 Storytelling Ambiental

**Sin texto, se cuenta la historia mediante:**

1. **Visual:**
   - Sala 1: Árboles marchitos, hojas oscuras
   - Sala 2: Ruinas antiguas con símbolos de runas grabados
   - Sala 3: Cristales corruptos (púrpuras vs. azules puros)
   - Sala Jefe: Cristal central pulsante con energía púrpura

2. **Enemigos:**
   - Sombras Corruptas: Criaturas del bosque transformadas
   - Guardián: Tenía propósito noble, ahora está esclavizado

3. **Progresión:**
   - Corrupción aumenta visualmente en cada sala
   - Al derrotar al jefe: Todo vuelve a colores naturales (verde, azul)

---

## 11. PLAN DE DESARROLLO

### 11.1 Metodología

**Enfoque:** Desarrollo iterativo ágil, sprints de 1 semana

**Equipo Mínimo (Indie):**
- 1 Programador (puede ser solo)
- 1 Artista (o usar assets gratuitos temporales)
- 1 Diseñador de sonido (o usar assets temporales)

**Si es proyecto individual:** Priorizar programación → Arte → Audio

---

### 11.2 Cronograma (12 Semanas)

#### **Semana 1-2: Fundación (P0.1)**
- [ ] Setup del proyecto (motor, control versiones)
- [ ] Movimiento del jugador (WASD, 8 direcciones)
- [ ] Cámara fija
- [ ] 1 sala de prueba con colisiones
- [ ] Sistema de transición entre salas básico

**Entregable:** Jugador puede moverse en sala vacía

---

#### **Semana 3-4: Runas y Combate (P0.2)**
- [ ] Sistema de selección de runas (FSM completa)
- [ ] UI de runas (iconos + cooldowns)
- [ ] Ataque básico del jugador
- [ ] 1 combinación funcional (Dardo Ígneo)
- [ ] Sistema de vida y maná
- [ ] Enemigo dummy (recibe daño, no ataca)

**Entregable:** Jugador puede atacar y usar 1 combinación

---

#### **Semana 5-6: Runas Completas (P1 Parcial)**
- [ ] Las 3 runas individuales funcionales
- [ ] Las 3 combinaciones completas
- [ ] Sistema de cooldowns refinado
- [ ] Efectos visuales básicos (partículas simples)
- [ ] SFX placeholder para todas las habilidades

**Entregable:** Todas las runas son jugables

---

#### **Semana 7-8: Enemigos y Salas (P1 Completo)**
- [ ] Enemigo básico con IA (FSM completa)
- [ ] Jefe con Fase 1 funcional
- [ ] Las 4 salas diseñadas (layout básico)
- [ ] Puzzles de bloques empujables
- [ ] Sistema de daño enemigo → jugador

**Entregable:** Juego completo pero sin pulir

---

#### **Semana 9: Jefe y Balance (P1 Refinamiento)**
- [ ] Jefe Fase 2 completa
- [ ] Balanceo de vida/daño de todos los enemigos
- [ ] Balanceo de cooldowns y costos de maná
- [ ] Checkpoint en Sala 3
- [ ] Pantallas de muerte y victoria

**Entregable:** Juego completable de inicio a fin

---

#### **Semana 10: Pulido Visual (P2)**
- [ ] Arte final para jugador (o assets finales)
- [ ] Arte final para enemigos
- [ ] Tilesets completos para las 4 salas
- [ ] Efectos visuales mejorados (fuego, explosiones)
- [ ] Animaciones completas

**Entregable:** Juego visualmente completo

---

#### **Semana 11: Pulido Audio y UI (P2)**
- [ ] Música para todas las salas
- [ ] SFX finales (reemplazar placeholders)
- [ ] UI pulida (menús, HUD)
- [ ] Tutorial completo con carteles
- [ ] Transiciones suaves entre salas

**Entregable:** Juego con feedback completo

---

#### **Semana 12: Testing y Launch (P2 Final)**
- [ ] Playtesting extensivo (5+ personas)
- [ ] Corrección de bugs críticos
- [ ] Optimización de performance
- [ ] Builds finales (Windows + WebGL)
- [ ] Publicación en Itch.io
- [ ] Trailer/screenshots

**Entregable:** Juego publicado y jugable

---

### 11.3 Priorización Actualizada

#### **P0 - Crítico** (Semanas 1-4)
- Movimiento funcional
- Sistema de runas básico
- Al menos 1 combinación
- 1 sala navegable
- Transición entre salas

#### **P1 - Alto** (Semanas 5-9)
- Las 3 runas completas
- Las 3 combinaciones
- Enemigo básico con IA
- Jefe con 2 fases
- 4 salas diseñadas
- Sistema de vida/daño completo

#### **P2 - Medio** (Semanas 10-11)
- Arte final
- Audio completo
- UI pulida
- Tutorial
- VFX/SFX de calidad

#### **P3 - Bajo** (Post-Launch)
- Partículas avanzadas
- Música dinámica
- Narrativa extendida
- Contenido adicional

---

### 11.4 Definición de "Terminado" (MVP)

El juego está completo cuando cumple **TODOS** estos criterios:

**Funcionalidad:**
- [ ] Tutorial enseña todas las mecánicas (100% comprensión en tests)
- [ ] Las 4 salas son completables sin bugs bloqueantes
- [ ] Las 3 runas + 3 combinaciones funcionan correctamente
- [ ] El jefe es derrotable usando las mecánicas enseñadas
- [ ] Muerte y victoria tienen pantallas funcionales
- [ ] Reintentar funciona correctamente

**Performance:**
- [ ] 60 FPS constantes en hardware moderno (i5, GTX 1050 o equivalente)
- [ ] Sin crashes en 5 playthroughs completos
- [ ] Tiempo de carga <1s por sala

**Calidad:**
- [ ] Feedback visual para TODAS las acciones (ataques, habilidades, daño)
- [ ] Feedback sonoro para TODAS las acciones principales
- [ ] UI legible y funcional
- [ ] Controles responsivos (input lag <50ms)

**Testing:**
- [ ] Al menos 5 testers externos completan el juego
- [ ] 80%+ de testers entienden las mecánicas sin ayuda externa
- [ ] Duración promedio: 30-60 minutos
- [ ] Feedback positivo en "feeling" del combate

**Release:**
- [ ] Build de Windows funcional
- [ ] Build WebGL funcional
- [ ] Página de Itch.io con descripción, screenshots, controles
- [ ] Al menos 1 trailer/GIF de gameplay

---

## 12. POST-MVP (Ideas para el Futuro)

### 12.1 Features Post-Launch

**Corto Plazo (Patch 1.1):**
- Sistema de guardado (checkpoints persistentes)
- Más tipos de enemigos (2-3 variantes)
- Dificultad seleccionable (Fácil/Normal/Difícil)
- Estadísticas al final (muertes, tiempo, combos usados)

**Mediano Plazo (Patch 1.5):**
- 2 runas nuevas (Hielo, Rayo) = 10 combinaciones nuevas
- 2 salas adicionales
- Sistema de mejoras (upgrades de cooldown/daño)
- Segundo jefe

**Largo Plazo (Versión 2.0):**
- Modo New Game+
- Desafíos/achievements
- Modo Boss Rush
- Speedrun timer
- Leaderboards

---

### 12.2 Monetización (Opcional)

**Si se busca monetizar:**
- Precio sugerido: $3-5 USD (juego corto, indie)
- Plataformas: Steam, Itch.io (paid), Epic Games Store
- Marketing: Reddit (r/IndieGaming), Twitter, TikTok (gameplay clips)

**Modelo Freemium (Alternativa):**
- Juego gratis en WebGL
- Versión premium: Sin ads, contenido extra, builds descargables

---

## 13. RIESGOS Y MITIGACIÓN

### 13.1 Riesgos Técnicos

| Riesgo | Impacto | Probabilidad | Mitigación |
|--------|---------|--------------|------------|
| Performance issues (FPS bajo) | Alto | Media | Profiling temprano, object pooling, optimización constante |
| Bugs de colisión (jugador atraviesa paredes) | Alto | Alta | Testing exhaustivo, usar sistemas de colisión del motor |
| Cooldowns desincronizados | Medio | Media | Sistema de cooldown robusto desde el inicio, tests unitarios |
| Balance pobre (muy fácil/difícil) | Alto | Alta | Playtesting temprano y frecuente (cada 2 semanas) |
| Input lag | Medio | Baja | Usar event-driven input, evitar Update polling |

---

### 13.2 Riesgos de Diseño

| Riesgo | Impacto | Probabilidad | Mitigación |
|--------|---------|--------------|------------|
| Mecánicas confusas | Alto | Alta | Tutorial extensivo, feedback de testers tempranos |
| Poca variedad de enemigos | Medio | Alta | ACEPTAR (es MVP), agregar post-launch |
| Juego muy corto | Medio | Media | Objetivo 45-60 min está bien para indie, enfocarse en calidad |
| Combos poco claros | Alto | Media | UI clara, indicadores visuales, práctica en tutorial |

---

### 13.3 Riesgos de Alcance

| Riesgo | Impacto | Probabilidad | Mitigación |
|--------|---------|--------------|------------|
| Scope creep (agregar features no planeadas) | Alto | Alta | SEGUIR ESTE GDD ESTRICTAMENTE, lista P3 para post-launch |
| Tiempo insuficiente | Alto | Media | Cronograma tiene 12 semanas, puede extenderse 2-4 más si es necesario |
| Recursos humanos limitados | Alto | Alta | Usar assets gratuitos temporales (Kenney.nl, OpenGameArt) |
| Burnout | Medio | Media | Sprints de 1 semana, descansos obligatorios, celebrar milestones |

---

## 14. REFERENTES Y INSPIRACIÓN

### 14.1 Juegos de Referencia

**Mecánicas:**
- **The Binding of Isaac:** Combate top-down, salas, combinaciones de items
- **Hades:** Sistema de habilidades, combate fluido, feedback excelente
- **Enter the Gungeon:** Boss patterns, esquiva con dash, ritmo de combate

**Sistema de Runas:**
- **Magicka:** Combinación de elementos para crear hechizos
- **Invoker (Dota 2):** Combinar orbes para invocar habilidades

**Arte:**
- **Hyper Light Drifter:** Pixel art atmosférico, paleta limitada
- **Dead Cells:** Animaciones fluidas, efectos de impacto satisfactorios

**Narrativa Minimalista:**
- **Journey:** Historia sin palabras, storytelling ambiental
- **Inside:** Atmósfera opresiva sin texto

---

### 14.2 Pillars Inspiracionales

1. **"Fácil de aprender, difícil de masterizar"** (Celeste)
2. **"Cada decisión importa"** (Into the Breach)
3. **"Feedback inmediato y satisfactorio"** (Doom 2016)
4. **"Menos es más"** (Minit)

---

## 15. MÉTRICAS DE ÉXITO

### 15.1 Métricas de Desarrollo

**Durante Desarrollo:**
- [ ] Completar cada sprint a tiempo (80%+ de tasks)
- [ ] Menos de 5 bugs críticos por milestone
- [ ] Playtesting cada 2 semanas con feedback positivo >70%

---

### 15.2 Métricas Post-Launch

**Indicadores de Calidad:**
- Tasa de completación: >60% de jugadores llegan al jefe
- Tiempo promedio: 45-60 minutos
- Reseñas positivas: >75% en Itch.io
- Tasa de regreso: >30% juegan 2+ veces

**Indicadores de Alcance:**
- 1000 descargas en primer mes (objetivo modesto)
- 50 comentarios/feedback
- 10 videos de gameplay en YouTube/Twitch

---

## 16. CONCLUSIÓN

### 16.1 Resumen Ejecutivo

**Runas del Núcleo** es un juego de acción top-down enfocado en:
- Sistema de combate basado en combinación de runas elementales
- 3 runas, 3 combinaciones, infinitas posibilidades tácticas
- 45-60 minutos de gameplay denso y pulido
- Narrativa minimalista con storytelling ambiental
- Arte pixel art atmosférico con feedback satisfactorio

**MVP completable en 12 semanas** con equipo pequeño o developer solo.

---

### 16.2 Visión a Largo Plazo

Este MVP es la **base sólida** para un juego potencialmente más grande:
- Sistema de runas escalable (fácil agregar nuevas)
- Motor de salas reutilizable para DLCs/expansiones
- Comunidad entusiasta que pida más contenido

**Objetivo Principal:** Crear un juego indie memorable que se destaque por su sistema de combate único y pulido.

---

### 16.3 Palabras Finales

> "No intentes hacer el juego perfecto. Haz el mejor juego que puedas en el tiempo asignado, publícalo, y mejóralo basándote en feedback real."

**¡Ahora a desarrollar!**

---

## APÉNDICES

### Apéndice A: Glosario de Términos

- **AoE (Area of Effect):** Habilidad que afecta un área, no un solo objetivo
- **DoT (Damage over Time):** Daño que se aplica gradualmente durante un período
- **FSM (Finite State Machine):** Sistema de estados para IA y mecánicas
- **Knockback:** Empuje que mueve un objeto por impacto
- **MVP (Minimum Viable Product):** Versión mínima jugable del juego
- **Pooling:** Reutilización de objetos para optimizar performance
- **Sprite:** Imagen 2D que representa un objeto en el juego
- **Tileset:** Conjunto de tiles (baldosas) para construir niveles
- **VFX (Visual Effects):** Efectos visuales como partículas, explosiones
- **Waypoint:** Punto de navegación para IA de patrullaje

---

### Apéndice B: Tablas de Balance Completas

#### Tabla 1: Estadísticas del Jugador
| Atributo | Valor | Notas |
|----------|-------|-------|
| Vida Máxima | 20 HP | 5 corazones visuales |
| Maná Máximo | 50 MP | Suficiente para 5 Dardos Ígneos |
| Velocidad Base | 4 u/s | Unidades por segundo |
| Daño Ataque Básico | 3 HP | Sin buffs |
| Cooldown Ataque | 0.5s | Muy rápido |
| Invulnerabilidad Post-Daño | 1.0s | I-frames generosos |
| Regeneración Maná | 2 MP/s | Comienza tras 1s sin usar |

---

#### Tabla 2: Runas Individuales (Comparativa)
| Runa | Cooldown | Maná | Utilidad Principal | Sinergia |
|------|----------|------|-------------------|----------|
| Fuego | 10s | 6 MP | Aumentar DPS | Combos ofensivos |
| Movimiento | 8s | 5 MP | Movilidad/Evasión | Combos rápidos |
| Escudo | 14s | 8 MP | Supervivencia | Combos defensivos |

**Análisis de Balance:**
- Movimiento tiene cooldown más bajo = más spam, pero menos impacto
- Escudo tiene cooldown más alto = más impacto, uso táctico
- Fuego es término medio, flexible

---

#### Tabla 3: Combinaciones (Comparativa)
| Combo | Cooldown | Maná | DPS Teórico | Rol Táctico |
|-------|----------|------|-------------|-------------|
| Dardo Ígneo (F+M) | 12s | 10 MP | 6 HP/12s = 0.5 DPS | Poke a distancia, seguro |
| Estallido (F+E) | 16s | 14 MP | 8 HP/16s = 0.5 DPS (AoE) | Burst contra grupos |
| Onda Cinética (E+M) | 18s | 12 MP | 0 DPS | Control, utilidad pura |

**Análisis de Balance:**
- Dardo y Estallido tienen mismo DPS teórico (balanceado)
- Estallido cuesta más maná pero es AoE (trade-off justo)
- Onda no hace daño pero es única herramienta de control

---

#### Tabla 4: Estadísticas de Enemigos
| Enemigo | HP | Daño | Velocidad | Tiempo para Matar (solo ataques básicos) |
|---------|----|----|-----------|----------------------------------------|
| Sombra Corrupta | 10 HP | 2 HP | 3 u/s | 3.34 ataques = ~2 segundos |
| Guardián (Fase 1) | 30 HP | 3-4 HP | 2.5 u/s | 10 ataques = ~7 segundos |
| Guardián (Fase 2) | 30 HP | 2-4 HP | 3.5 u/s | 10 ataques = ~7 segundos |

**Total de HP en el juego:**
- Sala 1: 20 HP (2 enemigos)
- Sala 2: 30 HP (3 enemigos)
- Sala 3: 60 HP (6 enemigos)
- Jefe: 60 HP
- **Total: 170 HP**

**Daño potencial del jugador (sin morir):**
- Solo ataques básicos: 3 HP × 60 ataques = 180 HP ✓ (suficiente)
- Con runas: Mucho más fácil

---

#### Tabla 5: Economía de Maná
| Escenario | Maná Gastado | Tiempo de Recarga | Viabilidad |
|-----------|--------------|-------------------|------------|
| 5 Dardos Ígneos seguidos | 50 MP | 25s (regeneración completa) | Posible pero ineficiente |
| Rotación F → M → F+M | 11 MP | 5.5s | Óptimo para DPS |
| Escudo + Estallido | 22 MP | 11s | Combo defensivo/ofensivo |
| Spam Destello | 10 MP (2 usos) | 5s entre usos | Viable para evasión |

**Conclusión:** El jugador puede usar ~4-5 habilidades antes de quedarse sin maná, pero la regeneración permite combates prolongados si se gestiona bien.

---

### Apéndice C: Flowcharts de Sistemas Críticos

#### Flowchart 1: Sistema de Selección de Runas
```
[Jugador presiona E/R/T]
		↓
	¿Runa en cooldown?
	/              \
  SÍ               NO
   ↓                ↓
[Sonido error]  ¿Suficiente maná?
[Return]        /              \
			  SÍ               NO
			   ↓                ↓
	   ¿selectedRunes = 0?  [Sonido no_mana]
	   /              \      [Return]
	 SÍ               NO
	  ↓                ↓
[Add runa]      ¿selectedRunes = 1?
[Highlight UI]  /              \
[Sonido select] SÍ             NO (= 2)
				↓               ↓
		 ¿Misma runa?      [Imposible]
		 /          \
	   SÍ           NO
		↓            ↓
	[Return]    [Add segunda runa]
				[Mostrar "ESPACIO para combo"]
				[Sonido combo_ready]
						↓
				[Esperar ESPACIO]
						↓
				[Ejecutar Combinación]
				[Aplicar cooldowns × 2]
				[Consumir maná]
				[Clear selection]
```

---

#### Flowchart 2: Sistema de Combate (Recibir Daño)
```
[Enemigo ataca al jugador]
		↓
	¿Jugador invulnerable?
	/              \
  SÍ               NO
   ↓                ↓
[Ignorar]    ¿Escudo activo?
[Return]     /              \
		   SÍ               NO
			↓                ↓
	[Escudo absorbe]  [Jugador recibe daño]
	[Reducir HP escudo] [HP -= daño]
			↓                ↓
	¿Escudo roto?      ¿HP <= 0?
	/          \       /          \
  SÍ           NO    SÍ           NO
   ↓            ↓     ↓            ↓
[40% reducción] [Return] [Morir]  [Invulnerabilidad 1s]
[1s duración]              ↓      [Flash animación]
   ↓                    [Animación] [Sonido hurt]
[Return]                [Pantalla muerte] [Return]
							  ↓
						[Reintentar sala]
```

---

#### Flowchart 3: IA Enemiga (Transiciones de Estado)
```
				[PATROL]
					↓
		¿Jugador en radio detección?
		/                      \
	  SÍ                       NO
	   ↓                        ↓
	[CHASE]              [Seguir patrullando]
	   ↓
   ¿Jugador en radio ataque?
   /                      \
 SÍ                       NO
  ↓                        ↓
[ATTACK]           ¿Jugador fuera 3s?
  ↓                /              \
¿Cooldown listo? SÍ              NO
/            \    ↓               ↓
SÍ          NO  [RETURN]     [Seguir persiguiendo]
↓            ↓     ↓
[Atacar]  [Esperar] [Volver a waypoint]
↓            ↓         ↓
[Cooldown]  [Return] ¿Llegó al waypoint?
↓                    /              \
[Return]          SÍ               NO
				   ↓                ↓
				[PATROL]      [Seguir regresando]

* En cualquier momento:
  [Recibe stun] → [STUNNED 0.8s] → [CHASE]
```

---

### Apéndice D: Checklist de Assets

#### Assets de Arte Necesarios

**Jugador:**
- [ ] Sprite sheet: Idle (2 frames)
- [ ] Sprite sheet: Walk 4 direcciones (4 frames cada una) = 16 frames
- [ ] Sprite sheet: Attack (3 frames)
- [ ] Sprite sheet: Hurt (2 frames)
- [ ] Sprite sheet: Dash (2 frames)
- [ ] VFX: Aura de Fuego (8 frames, loop)
- [ ] VFX: Escudo (sprite overlay estático)
- [ ] VFX: Trail de Destello (3 frames, fade out)

**Enemigos:**
- [ ] Sombra Corrupta: Idle (2 frames)
- [ ] Sombra Corrupta: Walk (4 frames)
- [ ] Sombra Corrupta: Attack (3 frames)
- [ ] Sombra Corrupta: Death (4 frames)
- [ ] Guardián: Idle (4 frames)
- [ ] Guardián: Walk (6 frames)
- [ ] Guardián: Todas las animaciones de ataque (20+ frames total)
- [ ] Guardián: Phase transition (8 frames)
- [ ] Guardián: Death (10 frames)

**Proyectiles y Habilidades:**
- [ ] Dardo Ígneo: Sprite principal (16x16px)
- [ ] Dardo Ígneo: Trail de fuego (8 frames)
- [ ] Dardo Ígneo: Explosión de impacto (6 frames)
- [ ] Estallido: Onda expansiva (8 frames)
- [ ] Onda Cinética: Cono de empuje (4 frames)
- [ ] Proyectiles del Jefe: Orbe oscuro (2 frames, loop)

**Partículas:**
- [ ] Fuego: Sprite 4x4px (5 variantes de color)
- [ ] Chispas: Sprite 2x2px (3 variantes)
- [ ] Humo: Sprite 8x8px (4 frames)
- [ ] Brillo: Sprite 8x8px (gradiente radial)

**Entorno - Tilesets:**
- [ ] Bosque: Suelo (grass, dirt) - 4 variantes
- [ ] Bosque: Árboles - 3 tamaños (32x64, 32x96, 64x96px)
- [ ] Bosque: Arbustos, rocas, flores (16 objetos decorativos)
- [ ] Ruinas: Suelo (piedra) - 3 variantes
- [ ] Ruinas: Columnas, muros, bloques - 10 objetos
- [ ] Caverna: Suelo (roca oscura) - 3 variantes
- [ ] Caverna: Estalagmitas, cristales - 8 objetos
- [ ] Sala Jefe: Suelo ritual - único
- [ ] Sala Jefe: Cristal central (32x32px, 4 frames)
- [ ] Sala Jefe: Pilares (32x32px)

**Objetos Interactivos:**
- [ ] Bloque empujable (32x32px)
- [ ] Placa de presión (32x32px, 2 estados)
- [ ] Puerta (32x64px, animación de apertura 4 frames)
- [ ] Cofre (32x32px, 2 estados: cerrado/abierto)
- [ ] Checkpoint (32x32px, brilla)
- [ ] Cartel de tutorial (32x48px)

**UI:**
- [ ] Iconos de runas: Fuego, Escudo, Movimiento (48x48px cada uno)
- [ ] Barra de vida: Corazón lleno/vacío (16x16px)
- [ ] Barra de maná: Fondo y líquido (200x20px)
- [ ] Marco de cooldown (48x48px, transparente)
- [ ] Botones de menú (300x50px, 3 estados: normal/hover/pressed)
- [ ] Fondos de pantalla: Menú, Victoria, Muerte
- [ ] Logo del juego (alta resolución para pantalla título)

**Total estimado:** ~200-250 sprites/frames individuales

---

#### Assets de Audio Necesarios

**Música (8 pistas):**
- [ ] Main Menu (loop 2 min)
- [ ] Tutorial (loop 1.5 min)
- [ ] Forest - Sala 1 (loop 2 min)
- [ ] Ruins - Sala 2 (loop 2 min)
- [ ] Cave - Sala 3 (loop 2 min)
- [ ] Boss Phase 1 (loop 1.5 min)
- [ ] Boss Phase 2 (loop 1.5 min)
- [ ] Victory Theme (30s, no loop)

**SFX del Jugador (30+ sonidos):**
- [ ] Footsteps (4 variantes, alternados)
- [ ] Attack basic (3 variantes)
- [ ] Hit enemy (3 variantes)
- [ ] Hit wall (1 sonido)
- [ ] Dash start (1 sonido)
- [ ] Dash land (1 sonido)
- [ ] Hurt (3 variantes)
- [ ] Death (1 sonido)
- [ ] Fire Rune activate (1 sonido)
- [ ] Fire Rune active (loop ambiental)
- [ ] Dash Rune (1 sonido)
- [ ] Shield Rune activate (1 sonido)
- [ ] Shield active (loop zumbido)
- [ ] Shield impact (1 sonido)
- [ ] Shield break (1 sonido)
- [ ] Fiery Dart shoot (1 sonido)
- [ ] Fiery Dart fly (loop)
- [ ] Fiery Dart impact (1 sonido)
- [ ] Core Burst charge (0.1s)
- [ ] Core Burst explosion (1 sonido)
- [ ] Kinetic Wave charge (0.1s)
- [ ] Kinetic Wave release (1 sonido)

**SFX de Enemigos (15+ sonidos):**
- [ ] Shadow detect (1 sonido)
- [ ] Shadow attack (1 sonido)
- [ ] Shadow hurt (2 variantes)
- [ ] Shadow death (1 sonido)
- [ ] Boss spawn (1 sonido)
- [ ] Boss charge prep (1 sonido)
- [ ] Boss charge execute (1 sonido)
- [ ] Boss slam (1 sonido)
- [ ] Boss shockwave (1 sonido)
- [ ] Boss projectile shoot (1 sonido × 3 = rápida sucesión)
- [ ] Boss phase transition (1 sonido)
- [ ] Boss hurt (2 variantes)
- [ ] Boss death (1 sonido)

**SFX de UI (10 sonidos):**
- [ ] Button hover (1 sonido)
- [ ] Button click (1 sonido)
- [ ] Rune select (1 sonido)
- [ ] Combo ready (1 sonido)
- [ ] Cancel selection (1 sonido)
- [ ] Cooldown complete (1 sonido)
- [ ] No mana (1 sonido)
- [ ] Chest open (1 sonido)
- [ ] Checkpoint activate (1 sonido)
- [ ] Door open (1 sonido)

**SFX de Ambiente (opcional, 5 sonidos):**
- [ ] Forest ambience (loop)
- [ ] Ruins ambience (loop)
- [ ] Cave ambience (loop)
- [ ] Boss room ambience (loop)
- [ ] Wind (loop)

**Total:** ~60-70 archivos de audio

---

### Apéndice E: Herramientas y Recursos Recomendados

#### Assets Gratuitos (Placeholder/Final)

**Arte:**
- **Kenney.nl:** Colecciones masivas de sprites 2D gratuitos (CC0)
- **OpenGameArt.org:** Sprites, tilesets, UI (varias licencias)
- **Itch.io Asset Packs:** Muchos gratuitos o "pay what you want"
- **CraftPix:** Algunos packs gratuitos de calidad

**Audio:**
- **Freesound.org:** SFX (Creative Commons)
- **OpenGameArt.org:** Música y SFX
- **Incompetech:** Música libre de Kevin MacLeod (CC BY)
- **ZapSplat:** SFX gratuitos con registro

**Fuentes:**
- **Google Fonts:** Fuentes gratuitas de calidad
- **DaFont:** Fuentes pixel art retro

---

#### Software Recomendado

**Desarrollo:**
- **Godot Engine 4.2+:** Gratuito, excelente para 2D
  - Ventajas: Open source, GDScript fácil, exportación web simple
  - Desventajas: Menos recursos que Unity
- **Unity 2022 LTS:** Gratuito hasta $100k/año de revenue
  - Ventajas: Mucha documentación, Asset Store
  - Desventajas: Más pesado, curva de aprendizaje

**Arte:**
- **Aseprite ($20):** Industria estándar para pixel art
  - Alternativa gratuita: **Piskel** (web-based)
- **Tiled:** Editor de mapas gratuito, exporta a JSON/XML
- **GIMP:** Photoshop gratuito para edición general

**Audio:**
- **Audacity:** Edición de audio gratuita
- **LMMS:** DAW gratuito para música
- **Bfxr/Chiptone:** Generadores de SFX retro (web-based)
- **Bosca Ceoil:** Creador de música simple y gratuito

**Otros:**
- **VS Code:** Editor de código
- **Git + GitHub:** Control de versiones
- **Trello/Notion:** Gestión de tareas
- **OBS Studio:** Grabación de trailers/gameplay

---

### Apéndice F: Script de Playtesting

#### Protocolo de Testing (Para Testers Externos)

**Pre-Test:**
1. No proporcionar información más allá de:
   - "Es un juego de acción top-down"
   - "Usa runas para combatir"
2. Observar sin intervenir (solo si se atascan >5 minutos)
3. Pedir que "piensen en voz alta" mientras juegan

**Durante el Test:**
**Observar y anotar:**
- [ ] ¿Entiende los controles inmediatamente?
- [ ] ¿Lee los carteles del tutorial?
- [ ] ¿Usa las combinaciones o solo runas individuales?
- [ ] ¿Muere más de 3 veces en la misma sala? (muy difícil)
- [ ] ¿Se salta enemigos o explora todo?
- [ ] ¿Frustraciones visibles? (suspirar, maldecir, abandonar controles)
- [ ] ¿Sonríe o se emociona en algún momento? (feedback positivo)

**Post-Test (Encuesta):**
1. Del 1-10, ¿qué tan claro fue el tutorial?
2. ¿Cuál fue tu combinación favorita? ¿Por qué?
3. ¿Hubo algún momento donde no supiste qué hacer?
4. ¿El jefe fue justo o frustrante?
5. Del 1-10, ¿qué tan satisfactorio se sintió el combate?
6. ¿Algo que cambiarías?
7. ¿Volverías a jugar?

**Métricas a Registrar:**
- Tiempo total de juego
- Número de muertes por sala
- ¿Completó el juego? (Sí/No)
- Si abandonó, ¿en qué punto?

---

### Apéndice G: Comandos de Debug (Para Desarrollo)

**Atajos de Teclado de Debug (remover en release):**
- **F1:** God Mode (invulnerable)
- **F2:** Maná infinito
- **F3:** Cooldowns instantáneos
- **F4:** Matar todos los enemigos en sala
- **F5:** Saltar a siguiente sala
- **F6:** Mostrar hitboxes/colliders
- **F7:** Slow motion (50% velocidad)
- **F8:** Mostrar estadísticas (FPS, RAM, entidades)
- **F9:** Recargar sala actual
- **F10:** Screenshot

**Comandos de Consola (si se implementa):**
```
/setHP <cantidad>      - Establece vida del jugador
/setMana <cantidad>    - Establece maná del jugador
/spawn <enemigo>       - Spawnea un enemigo
/teleport <sala>       - Salta a sala específica
/setSpeed <valor>      - Cambia velocidad del jugador
/killall               - Mata todos los enemigos
```

---

### Apéndice H: Consideraciones de Accesibilidad

**Inclusión Mínima para MVP:**

1. **Controles:**
   - [ ] Remapeo de teclas (post-MVP, pero considerar arquitectura)
   - [ ] Soporte para gamepad (opcional MVP, altamente recomendado)

2. **Visual:**
   - [ ] Opción de reducir screen shake (para sensibilidad al movimiento)
   - [ ] Contraste alto entre jugador/enemigos/fondo
   - [ ] UI con fuentes legibles (mínimo 16px)

3. **Audio:**
   - [ ] Controles de volumen separados (Música/SFX)
   - [ ] Subtítulos para cualquier diálogo (no aplicable en MVP minimalista)

4. **Dificultad:**
   - [ ] Permitir reintentos ilimitados sin penalización
   - [ ] Checkpoint en Sala 3 (ya incluido)
   - [ ] Considerar modo "Fácil" post-MVP (enemigos con 70% HP)

---

### Apéndice I: Plantilla de Bug Report

```markdown
## Bug Report Template

**Título:** [Descripción breve del bug]

**Prioridad:** [Crítico / Alto / Medio / Bajo]
- Crítico: Crash, imposible continuar
- Alto: Mecánica core rota, bug visual severo
- Medio: Inconveniente pero jugable
- Bajo: Cosmético, typo

**Pasos para Reproducir:**
1. Ir a [sala/situación]
2. Hacer [acción específica]
3. Observar [resultado incorrecto]

**Resultado Esperado:**
[Qué debería pasar]

**Resultado Actual:**
[Qué pasa en realidad]

**Capturas/Video:**
[Adjuntar si es posible]

**Información del Sistema:**
- OS: Windows 10 / Linux / Web
- Versión del Juego: v0.5.2
- Hardware: [GPU, RAM si es relevante]

**Notas Adicionales:**
[Cualquier contexto extra]
```

---

### Apéndice J: Créditos y Atribuciones

**Plantilla de Créditos (Para Pantalla Final):**

```
═══════════════════════════════
	RUNAS DEL NÚCLEO
═══════════════════════════════

Desarrollado por:
[Tu Nombre / Estudio]

Programación:
[Nombres]

Arte:
[Nombres]

Música y Sonido:
[Nombres]

Diseño de Juego:
[Nombres]

───────────────────────────────

Herramientas Utilizadas:
[Godot Engine / Unity]
Aseprite
Audacity

───────────────────────────────

Assets de Terceros:
[Listar cualquier asset usado con crédito]
[Incluir licencias CC BY, etc.]

───────────────────────────────

Agradecimientos Especiales:
[Playtesters]
[Mentores]
[Comunidad]

───────────────────────────────

Creado en [Ciudad, País]
[Año]

───────────────────────────────

Gracias por jugar ❤️

[Links a redes sociales / website]
═══════════════════════════════
```

---

## DOCUMENTO FINAL

**Este GDD es un documento vivo.** Debe actualizarse durante el desarrollo cuando:
- Se descubren problemas de diseño
- El playtesting revela issues
- Limitaciones técnicas requieren cambios
- Se agregan features post-MVP

**Control de Versiones del GDD:**
- v1.0 (Actual): GDD completo para inicio de desarrollo
- v1.1: Después de primer sprint (ajustes tempranos)
- v1.5: Mitad del desarrollo (balanceo intermedio)
- v2.0: Pre-release (GDD final del MVP)

---

**Última Actualización:** Noviembre 2025  
**Próxima Revisión:** Después del Sprint 2 (Semana 4)

---

## ¡A CREAR!

**Todo lo necesario está aquí.** Ahora es momento de ejecutar:

1. **Setup del proyecto** (Día 1)
2. **Movimiento del jugador** (Día 2-3)
3. **Primera sala jugable** (Día 4-5)
4. **Sistema de runas** (Semana 2)
5. ...y seguir el cronograma de 12 semanas

**Recuerda:**
> "El juego perfecto no existe. El juego terminado y jugable, sí."

**¡Buena suerte, desarrollador!
