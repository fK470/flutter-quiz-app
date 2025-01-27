import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'quiz_database.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE quiz(
        id INTEGER PRIMARY KEY,
        question TEXT,
        option1 TEXT,
        option2 TEXT,
        option3 TEXT,
        option4 TEXT,
        answer TEXT
      )
    ''');

    // 初期データの挿入
    await _insertInitialData(db);
  }

  Future<void> _insertInitialData(Database db) async {
    final List<Map<String, dynamic>> quizData = [
      {
        'question': 'Flutterはどの会社によって開発されましたか？',
        'option1': 'Google',
        'option2': 'Facebook',
        'option3': 'Apple',
        'option4': 'Microsoft',
        'answer': 'Google',
      },
      {
        'question': 'Dart言語の主な用途は何ですか？',
        'option1': 'ウェブ開発',
        'option2': 'ゲーム開発',
        'option3': 'モバイルアプリ開発',
        'option4': 'データ分析',
        'answer': 'モバイルアプリ開発',
      },
      {
        'question': 'Flutterでの「Widget」の主な役割は何ですか？',
        'option1': 'データベース管理',
        'option2': 'UI要素の構築',
        'option3': 'ネットワーク通信',
        'option4': 'データ解析',
        'answer': 'UI要素の構築',
      },
      {
        'question': 'ホットリロードの主な利点は何ですか？',
        'option1': 'アプリのサイズを縮小する',
        'option2': 'コードの変更を即座に反映する',
        'option3': 'データベースのパフォーマンスを向上させる',
        'option4': 'ネットワークの遅延を減らす',
        'answer': 'コードの変更を即座に反映する',
      },
      {
        'question': 'Flutterで使用されるプログラミング言語は何ですか？',
        'option1': 'Java',
        'option2': 'Kotlin',
        'option3': 'Swift',
        'option4': 'Dart',
        'answer': 'Dart',
      },
    ];

    for (final data in quizData) {
      await db.insert('quiz', data);
    }
  }

  Future<List<Map<String, dynamic>>> getQuizData() async {
    final db = await database;
    return await db.query('quiz');
  }
}
