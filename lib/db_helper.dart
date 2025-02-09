import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  /// データベースのシングルトンインスタンスを取得
  ///
  /// キャッシュされたインスタンスがあれば、それを返す。
  /// そうでなければ、[_initDatabase] を使ってデータベースを初期化し、その結果をキャッシュする。
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// データベースを以下の手順で初期化
  /// 1. アプリのドキュメントディレクトリを取得
  /// 2. [quiz_database.db]という名前のデータベースファイルのパスを構築
  /// 3. 指定されたパスでデータベースを[version]を1で[_onCreate]コールバックを設定し、開く
  ///
  /// データベースが正常に開かれたら、[Database]インスタンスを返します。
  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'quiz_database.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  /// データベースのスキーマを作成し、初期データを挿入
  ///
  /// 1. SQLコマンドを実行して、[quiz] テーブルを作成
  ///
  /// 2. [_insertInitialData] テーブルにデフォルトのクイズデータを挿入
  ///
  /// @param db テーブル作成が実行されるデータベースインスタンス。
  /// @param version データベーススキーマのバージョン番号。
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

    await _insertInitialData(db);
  }

  /// データベースに初期のクイズデータを挿入
  ///
  /// この関数は次の手順を実行します:
  /// 1. アセットファイル 'lib/initQuizData.json' から JSON 文字列を読み込みます。
  /// 2. JSON 文字列をデコードして、クイズエントリのリストに変換します。
  /// 3. 各クイズエントリを反復し、問題、選択肢、および回答を含むマップを構築します。
  /// 4. 生成された各クイズエントリを、指定されたデータベースの 'quiz' テーブルに挿入します。
  ///
  /// @param db クイズデータを挿入する対象のデータベースインスタンス。
  Future<void> _insertInitialData(Database db) async {
    final String jsonString =
        await rootBundle.loadString('lib/initQuizData.json');
    final List<dynamic> quizData = jsonDecode(jsonString);

    for (final data in quizData) {
      final Map<String, dynamic> quizEntry = {
        'question': data['question'],
        'option1': data['option1'],
        'option2': data['option2'],
        'option3': data['option3'],
        'option4': data['option4'],
        'answer': data[data['answer']]
      };
      await db.insert('quiz', quizEntry);
    }
  }

  /// データベースからクイズデータを取得[SELECT]
  ///
  /// 非同期的にデータベースインスタンスを取得し、'quiz' テーブルに対してクエリを実行
  ///
  /// @return `Future List<Map<String, dynamic>>` クイズデータのリスト
  Future<List<Map<String, dynamic>>> getQuizData() async {
    final db = await database;
    return await db.query('quiz');
  }

  /// データベースをリセット
  ///
  /// 1. [getApplicationDocumentsDirectory] を使用してアプリケーションのドキュメントディレクトリを取得
  /// 2. ドキュメントディレクトリのパスと 'quiz_database.db' を結合し、データベースファイルの完全なパスを構築します。
  /// 3. [deleteDatabase]を使用して、構築されたパス上のデータベースを削除します。
  /// 4. メモリ内のデータベース参照[_database]を null に設定します。
  /// 5. database getter を await して、データベースを再初期化し、新しいインスタンスを確保します。
  Future<void> resetDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'quiz_database.db');
    await deleteDatabase(path);
    _database = null;
    await database;
  }
}
