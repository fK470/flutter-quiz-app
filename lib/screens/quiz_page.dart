import 'package:flutter/material.dart';
import 'package:quiz_app/db_helper.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  QuizPageState createState() => QuizPageState();
}

class QuizPageState extends State<QuizPage> {
  List<Map<String, dynamic>> _quizData = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _quizCompleted = false;

  @override
  void initState() {
    super.initState();
    _loadQuizData();
  }

  Future<void> _loadQuizData() async {
    final quizData = await DatabaseHelper.instance.getQuizData();
    setState(() {
      _quizData = quizData;
    });
  }

  void _answerQuestion(String selectedAnswer) {
    if (_quizData[_currentQuestionIndex]['answer'] == selectedAnswer) {
      setState(() {
        _score++;
      });
    }
    _nextQuestion();
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _quizData.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      setState(() {
        _quizCompleted = true;
      });
    }
  }

  void _resetQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _score = 0;
      _quizCompleted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_quizData.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
        appBar: AppBar(
          title: const Text('4択クイズ'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _quizCompleted
                ? [
                    Text('クイズ終了！ 得点は $_score / ${_quizData.length}'),
                    ElevatedButton(
                      onPressed: _resetQuiz,
                      child: const Text('もう一度挑戦する'),
                    ),
                  ]
                : [
                    // クイズの進行状況を表示
                    Text(
                      '${_currentQuestionIndex + 1} / ${_quizData.length}',
                      style: const TextStyle(fontSize: 16),
                    ),

                    // クイズの問題文を表示
                    Text(
                      _quizData[_currentQuestionIndex]['question'],
                      style: const TextStyle(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 18),

                    // 回答ボタンを表示
                    ...[
                      _quizData[_currentQuestionIndex]['option1'],
                      _quizData[_currentQuestionIndex]['option2'],
                      _quizData[_currentQuestionIndex]['option3'],
                      _quizData[_currentQuestionIndex]['option4'],
                    ].map((option) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ElevatedButton(
                            onPressed: () => _answerQuestion(option),
                            child: Text(option),
                          ),
                        )),
                  ],
          ),
        ));
  }
}
