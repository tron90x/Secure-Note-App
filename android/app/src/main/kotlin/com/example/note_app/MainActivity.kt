package com.example.note_app

import io.flutter.embedding.android.FlutterActivity
import net.sqlcipher.database.SQLiteDatabase

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)
        SQLiteDatabase.loadLibs(this)
    }
}
