package com.dailytracker.app

import android.annotation.SuppressLint
import android.graphics.Bitmap
import android.net.Uri
import android.os.Bundle
import android.webkit.WebResourceRequest
import android.webkit.WebSettings
import android.webkit.WebView
import android.webkit.WebViewClient
import androidx.activity.OnBackPressedCallback
import androidx.appcompat.app.AppCompatActivity

class MainActivity : AppCompatActivity() {

  private lateinit var webView: WebView

  @SuppressLint("SetJavaScriptEnabled")
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    setContentView(R.layout.activity_main)

    webView = findViewById(R.id.webView)

    with(webView.settings) {
      javaScriptEnabled = true
      domStorageEnabled = true
      allowFileAccess = true
      allowContentAccess = true
      databaseEnabled = true
      mixedContentMode = WebSettings.MIXED_CONTENT_COMPATIBILITY_MODE
      loadWithOverviewMode = true
      useWideViewPort = true
      builtInZoomControls = false
      displayZoomControls = false
    }

    webView.webViewClient = object : WebViewClient() {
      override fun shouldOverrideUrlLoading(view: WebView?, request: WebResourceRequest?): Boolean {
        val url = request?.url ?: return false
        return routeInternalUrl(url)
      }

      override fun onPageStarted(view: WebView?, url: String?, favicon: Bitmap?) {
        super.onPageStarted(view, url, favicon)
      }
    }

    if (savedInstanceState == null) {
      webView.loadUrl(MAIN_PAGE)
    }

    onBackPressedDispatcher.addCallback(this, object : OnBackPressedCallback(true) {
      override fun handleOnBackPressed() {
        if (webView.canGoBack()) {
          webView.goBack()
        } else {
          finish()
        }
      }
    })
  }

  private fun routeInternalUrl(uri: Uri): Boolean {
    val path = uri.path.orEmpty()
    return when {
      path == "/client" || path == "/client.html" || uri.toString().endsWith("/client") -> {
        webView.loadUrl(CLIENT_PAGE)
        true
      }

      path == "/" || path.endsWith("/index.html") -> {
        webView.loadUrl(MAIN_PAGE)
        true
      }

      uri.scheme == "file" -> false
      else -> false
    }
  }

  override fun onSaveInstanceState(outState: Bundle) {
    super.onSaveInstanceState(outState)
    webView.saveState(outState)
  }

  override fun onRestoreInstanceState(savedInstanceState: Bundle) {
    super.onRestoreInstanceState(savedInstanceState)
    webView.restoreState(savedInstanceState)
  }

  companion object {
    private const val MAIN_PAGE = "file:///android_asset/index.html"
    private const val CLIENT_PAGE = "file:///android_asset/client.html"
  }
}
