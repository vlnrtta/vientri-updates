package com.example.vientri

import android.app.*
import android.content.Intent
import android.os.*
import android.speech.RecognitionListener
import android.speech.RecognizerIntent
import android.speech.SpeechRecognizer
import android.util.Log
import androidx.core.app.NotificationCompat
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.plugin.common.MethodChannel


class WakeWordService : Service() {

    companion object {
        const val ACTION_START_LISTENING = "ACTION_START_LISTENING"
        const val ACTION_STOP_LISTENING = "ACTION_STOP_LISTENING"
        const val ACTION_PAUSE = "ACTION_PAUSE"
        const val ACTION_RESUME = "ACTION_RESUME"
        const val CHANNEL_ID = "voice_service"
        const val NOTIFICATION_ID = 1
    }

    private lateinit var speechRecognizer: SpeechRecognizer
    private var escuchando = true
    private lateinit var recognizerIntent: Intent

    override fun onCreate() {
        super.onCreate()
        crearCanal()
        iniciarSpeechRecognizer()
        startForeground(NOTIFICATION_ID, crearNotificacion())
        iniciarEscucha()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {

            ACTION_START_LISTENING -> {
                escuchando = true
                iniciarEscucha()
                actualizarNotificacion()
            }

            ACTION_STOP_LISTENING -> {
                escuchando = false
                speechRecognizer.stopListening()
                actualizarNotificacion()
            }

            ACTION_PAUSE -> {
                escuchando = false
                speechRecognizer.stopListening()
            }

            ACTION_RESUME -> {
                if (!escuchando) {
                    escuchando = true
                    iniciarEscucha()
                }
            }
        }
        return START_STICKY
    }


    // ============================
    // SpeechRecognizer
    // ============================

    private fun iniciarSpeechRecognizer() {
        speechRecognizer = SpeechRecognizer.createSpeechRecognizer(this)

        recognizerIntent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
            putExtra(
                RecognizerIntent.EXTRA_LANGUAGE_MODEL,
                RecognizerIntent.LANGUAGE_MODEL_FREE_FORM
            )
            putExtra(RecognizerIntent.EXTRA_LANGUAGE, "es-AR")
            putExtra(RecognizerIntent.EXTRA_PARTIAL_RESULTS, true)
        }

        speechRecognizer.setRecognitionListener(object : RecognitionListener {

            override fun onResults(results: Bundle?) {
                procesarResultadosFinales(results)
                if (escuchando) iniciarEscucha()
            }

            override fun onPartialResults(partialResults: Bundle?) {
                mostrarParciales(partialResults) // SOLO LOG
            }

            override fun onError(error: Int) {
                if (escuchando) iniciarEscucha()
            }

            override fun onReadyForSpeech(params: Bundle?) {}
            override fun onBeginningOfSpeech() {}
            override fun onRmsChanged(rmsdB: Float) {}
            override fun onBufferReceived(buffer: ByteArray?) {}
            override fun onEndOfSpeech() {}
            override fun onEvent(eventType: Int, params: Bundle?) {}
        })

    }

    private fun mostrarParciales(bundle: Bundle?) {
        val texto = bundle
            ?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
            ?.firstOrNull()
            ?.lowercase()
            ?: return

        Log.d("WakeWordService", "🟡 Parcial: $texto")
    }


    private fun iniciarEscucha() {
        if (escuchando) {
            speechRecognizer.startListening(recognizerIntent)
        }
    }

    // ============================
    // Procesar comandos
    // ============================

    private fun procesarResultadosFinales(bundle: Bundle?) {
        val texto = bundle
            ?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
            ?.firstOrNull()
            ?.lowercase()
            ?: return

        Log.d("WakeWordService", "🟢 Final: $texto")

        // ============================
        // WAKE WORD
        // ============================
        if (
            texto.contains("vientri") ||
            texto.contains("vientre") ||
            texto.contains("bien tri")
        ) {
            abrirApp(null)
            mostrarNotificacionIniciar()
            return
        }

        // ============================
        // ENVIAR AUDIO + NOMBRE
        // ============================
        if (texto.startsWith("enviar audio")) {

            val nombre = texto
                .removePrefix("enviar audio a ")
                .removePrefix("enviar audio ")
                .trim()

            Log.d("WakeWordService", "🎯 Enviar audio a: $nombre")

            enviarComandoFlutter(
                "enviar_audio",
                nombre.ifEmpty { null }
            )
            return
        }

        // ============================
        // CAMBIAR A DESARROLLO
        // ============================
        if (texto.startsWith("cambiar a desarrollo") || texto.startsWith("modo desarrollo") || texto.startsWith("cambiar a modo desarrollo") 
            || texto.startsWith("cambiar a producción") || texto.startsWith("modo producción") || texto.startsWith("cambiar a modo producción")) {
            val modo = texto
                .removePrefix("cambiar a ")
                .removePrefix("modo ")
                .removePrefix("cambiar a modo ")
                .trim()

            Log.d("WakeWordService", "Cambiando a : $modo")

            enviarComandoFlutter(
                "cambiar_modo",
                modo.ifEmpty { null }
            )
            return
        }

        // ============================
        // NOMBRE CONTACTO CONTEXTUAL
        // ============================
        if (texto.startsWith("para ")) {

            val nombre = texto
                .removePrefix("para ")
                .trim()

            Log.d("WakeWordService", "🎯 Nombre contextual: $nombre")

            enviarComandoFlutter(
                "nombre_contacto",
                nombre.ifEmpty { null }
            )
            return
        }


        if (texto.contains("cancelar")) {
            enviarComandoFlutter("cancelar", null)
        }
    }

    private fun enviarComandoFlutter(comando: String, argumento: String?) {
        try {
            val engine = FlutterEngineCache
                .getInstance()
                .get("voice_engine")
                ?: return

            MethodChannel(
                engine.dartExecutor.binaryMessenger,
                "vientri/voice"
            ).invokeMethod(comando, argumento)

        } catch (e: Exception) {
            Log.e("WakeWordService", "Error enviando comando", e)
        }
    }

    // ============================
    // Abrir la app
    // ============================

    private fun abrirApp(accion: String?) {
        val intent = Intent(this, MainActivity::class.java).apply {
            flags =
                Intent.FLAG_ACTIVITY_NEW_TASK or
                Intent.FLAG_ACTIVITY_CLEAR_TOP or
                Intent.FLAG_ACTIVITY_SINGLE_TOP

            accion?.let {
                putExtra("accion", it)
            }
        }

        startActivity(intent)
    }


    // ============================
    // Notificación
    // ============================

    private fun crearCanal() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Escucha por voz",
                NotificationManager.IMPORTANCE_LOW
            )
            getSystemService(NotificationManager::class.java)
                .createNotificationChannel(channel)
        }
    }

    private fun crearNotificacion(): Notification {
        val accion = if (escuchando)
            NotificationCompat.Action(
                android.R.drawable.ic_media_pause,
                "Desactivar",
                pendingAction(ACTION_STOP_LISTENING)
            )
        else
            NotificationCompat.Action(
                android.R.drawable.ic_media_play,
                "Activar",
                pendingAction(ACTION_START_LISTENING)
            )

        val texto = if (escuchando)
            "Escuchando comandos de voz"
        else
            "Escucha desactivada"

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_btn_speak_now)
            .setContentTitle("Vientri")
            .setContentText(texto)
            .addAction(accion)
            .setOngoing(true)
            .build()
    }

    private fun actualizarNotificacion() {
        getSystemService(NotificationManager::class.java)
            .notify(NOTIFICATION_ID, crearNotificacion())
    }

    private fun pendingAction(action: String): PendingIntent {
        val intent = Intent(this, WakeWordService::class.java).apply {
            this.action = action
        }

        return PendingIntent.getService(
            this,
            action.hashCode(),
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    }

    private fun mostrarNotificacionIniciar() {
        val channelId = "voice_action"

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                "Acciones por voz",
                NotificationManager.IMPORTANCE_HIGH
            )
            getSystemService(NotificationManager::class.java)
                .createNotificationChannel(channel)
        }

        val intent = Intent(this, MainActivity::class.java).apply {
            flags =
                Intent.FLAG_ACTIVITY_NEW_TASK or
                Intent.FLAG_ACTIVITY_CLEAR_TOP or
                Intent.FLAG_ACTIVITY_SINGLE_TOP
        }

        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val notification = NotificationCompat.Builder(this, channelId)
            .setSmallIcon(android.R.drawable.ic_btn_speak_now)
            .setContentTitle("Vientri")
            .setContentText("Comando INICIAR detectado")
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setContentIntent(pendingIntent)
            .setAutoCancel(true)
            .setFullScreenIntent(pendingIntent, true) // 🔥
            .build()

        getSystemService(NotificationManager::class.java)
            .notify(2001, notification)
    }


    // ============================
    // Lifecycle
    // ============================

    override fun onDestroy() {
        speechRecognizer.destroy()
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
