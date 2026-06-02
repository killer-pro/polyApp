package sn.ept.pic

import android.os.Bundle
import com.google.android.gms.security.ProviderInstaller
import io.flutter.embedding.android.FlutterActivity
import android.util.Log

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        installSecurityProvider()
    }

    private fun installSecurityProvider() {
        try {
            ProviderInstaller.installIfNeeded(applicationContext)
            Log.d("SecurityProvider", "Security provider installed successfully.")
        } catch (e: Exception) {
            Log.e("SecurityProvider", "Failed to install security provider: ${e.message}")
        }
    }
}
