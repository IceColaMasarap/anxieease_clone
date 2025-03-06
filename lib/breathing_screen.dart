import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'services/breathing_service.dart';

class BreathingScreen extends StatefulWidget {
  const BreathingScreen({super.key});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen>
    with SingleTickerProviderStateMixin {
  late final AudioPlayer _audioPlayer;
  AnimationController? _animationController;
  final ValueNotifier<String> _currentPhase =
      ValueNotifier<String>('Get Ready');
  final ValueNotifier<bool> _isPlaying = ValueNotifier<bool>(false);
  final ValueNotifier<String> _motivationalMessage = ValueNotifier<String>('');
  bool _isDisposed = false;
  BreathingExercise? selectedExercise;

  final List<String> _motivationalMessages = [
    "You're doing great, keep breathing",
    "Let go of your worries with each breath",
    "Feel your anxiety melting away",
    "You are stronger than your anxiety",
    "Stay present in this moment",
    "You're taking control of your peace",
    "Each breath brings more calmness",
    "Trust in your inner strength",
    "You're safe and in control",
    "This feeling will pass",
    
    "Focus on your breath, nothing else matters",
    "Notice the rhythm of your breathing",
    "Be here, in this peaceful moment",
    "Your breath is your anchor",
    
    "Feel the tension leaving your body",
    "With each breath, you become more relaxed",
    "Your body knows how to find peace",
    "Embrace the feeling of calmness",
    
    "You have the power to calm your mind",
    "You're building inner strength",
    "Every breath makes you stronger",
    "You're taking care of yourself",
    
    "You're doing something positive for yourself",
    "Keep going, you're doing well",
    "This is your time for peace",
    "You deserve this moment of calm",
    
    "Anxiety cannot control you",
    "You are bigger than your worries",
    "Your breath is your safe space",
    "Peace is within your reach",
    
    "Feel your feet on the ground",
    "Notice the rise and fall of your chest",
    "Your breath connects mind and body",
    "You are grounded and secure",
    
    "Be gentle with yourself",
    "You're worth this moment of peace",
    "Accept yourself as you are",
    "You're taking positive steps",
    
    "This is your moment of peace",
    "Right here, right now, you're okay",
    "Each breath is a fresh start",
    "Find peace in this moment",
  ];

  int _lastMessageIndex = -1;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
  }

  @override
  Widget build(BuildContext context) {
    if (selectedExercise == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Breathing Exercises',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          backgroundColor: Colors.green.shade500,
          elevation: 0,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.green.shade500,
                Colors.green.shade50,
              ],
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                decoration: BoxDecoration(
                  color: Colors.green.shade500,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: const Text(
                  'Choose a breathing technique to help reduce anxiety and find your inner peace',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  itemCount: BreathingExercise.anxietyExercises.length,
                  itemBuilder: (context, index) {
                    final exercise = BreathingExercise.anxietyExercises[index];
                    return Hero(
                      tag: 'exercise_${exercise.name}',
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        child: Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          elevation: 4,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                selectedExercise = exercise;
                              });
                              _initializeExercise();
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.green.shade300,
                                              Colors.green.shade500,
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.green.shade200,
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.air,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              exercise.name,
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.green.shade50,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                '${_calculateTotalDuration(exercise)}s per cycle',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.green.shade700,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Text(
                                      exercise.description,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey.shade700,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildBreathingPattern(exercise),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        if (_isPlaying.value) {
          _stopExercise();
        }
        Navigator.of(context).pop();
        return false;
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.green.shade200,
                Colors.green.shade50,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: _buildContent(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black54),
            onPressed: () {
              if (_isPlaying.value) {
                _stopExercise();
              }
              Navigator.of(context).pop();
            },
          ),
          Expanded(
            child: Text(
              selectedExercise?.name ?? '',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildTimeChip(String text) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: Colors.green.shade700,
        ),
      ),
    );
  }

  Future<void> _initializeExercise() async {
    if (selectedExercise == null) return;

    // Dispose previous controller if exists
    _animationController?.dispose();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _getTotalCycleDuration()),
    );

    _animationController!.addStatusListener(_handleAnimationStatus);
    _animationController!.addListener(() {
      if (!_isDisposed && mounted) {
        setState(() {}); // Ensure the animation updates the UI
        // Update message every cycle
        if (_animationController!.value >= 0.99) {
          _updateMotivationalMessage();
        }
      }
    });

    // Initialize audio in the background
    await _setupAudio();

    // Show headphone recommendation after a short delay
    if (!_isDisposed) {
      await Future.delayed(const Duration(milliseconds: 300));
      if (!_isDisposed && mounted) {
        _showHeadphoneRecommendation();
      }
    }
  }

  int _calculateTotalDuration(BreathingExercise exercise) {
    return exercise.inhaleTime +
        exercise.holdTime +
        exercise.exhaleTime +
        exercise.holdOutTime;
  }

  int _getTotalCycleDuration() {
    if (selectedExercise == null) return 0;
    return _calculateTotalDuration(selectedExercise!);
  }

  Future<void> _setupAudio() async {
    if (selectedExercise?.soundUrl != null) {
      try {
        print('Setting up audio for ${selectedExercise!.name}');
        print('Audio file path: ${selectedExercise!.soundUrl}');
        await _audioPlayer.setAsset(selectedExercise!.soundUrl!);
        await _audioPlayer.setLoopMode(LoopMode.one);
        print('Audio setup completed successfully');
      } catch (e) {
        print('Audio setup failed: ${selectedExercise!.soundUrl} - Error: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Audio setup failed: $e'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } else {
      print('No audio file specified for ${selectedExercise?.name}');
    }
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (!_isDisposed && status == AnimationStatus.completed && mounted) {
      _animationController!.reset();
      _animationController!.forward();
      _updateMotivationalMessage();
    }
  }

  void _showHeadphoneRecommendation() {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {
        return Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              color: Colors.transparent,
              child: Center(
                child: TweenAnimationBuilder(
                  duration: const Duration(milliseconds: 200),
                  tween: Tween<double>(begin: 0.8, end: 1.0),
                  curve: Curves.easeOut,
                  builder: (context, double value, child) {
                    return Transform.scale(
                      scale: value,
                      child: child,
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.headphones,
                          size: 48,
                          color: Colors.green[600],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Best Experience with Headphones',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'For optimal relaxation, we recommend using headphones',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap anywhere to continue',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[400],
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _updateMotivationalMessage() {
    if (_isPlaying.value) {
      int newIndex;
      do {
        newIndex = (DateTime.now().microsecondsSinceEpoch % _motivationalMessages.length).toInt();
      } while (newIndex == _lastMessageIndex && _motivationalMessages.length > 1);
      
      _lastMessageIndex = newIndex;
      _motivationalMessage.value = _motivationalMessages[newIndex];
    }
  }

  void _startExercise() {
    if (_isDisposed || _animationController == null) return;
    _isPlaying.value = true;
    _updateMotivationalMessage();
    _animationController!.repeat();

    if (selectedExercise?.soundUrl != null) {
      print('Starting audio playback for ${selectedExercise!.name}');
      _audioPlayer.play().then((_) {
        print('Audio playback started successfully');
      }).catchError((e) {
        print('Error playing audio: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error playing audio: $e'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      });
    }
  }

  void _stopExercise() {
    if (_isDisposed || _animationController == null) return;
    _isPlaying.value = false;
    _currentPhase.value = 'Complete';
    _animationController!.stop();
    _animationController!.reset();
    
    print('Stopping audio playback');
    _audioPlayer.stop().then((_) {
      print('Audio playback stopped successfully');
    }).catchError((e) {
      print('Error stopping audio: $e');
    });
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildInfoCard(),
          const SizedBox(height: 16),
          Expanded(
            child: _buildBreathingAnimation(),
          ),
          _buildControlButton(),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            selectedExercise?.description ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
          const Divider(height: 20),
          Text(
            selectedExercise?.technique ?? '',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreathingAnimation() {
    if (_animationController == null) {
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.8, end: 1.2),
        duration: const Duration(seconds: 3),
        curve: Curves.easeInOut,
        builder: (context, value, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Outer ripple circles
              ...List.generate(3, (index) {
                final opacity = (1 - (index * 0.2));
                final scale = value + (index * 0.1);
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green.withOpacity(opacity * 0.3),
                    ),
                  ),
                );
              }).reversed,
              // Main breathing circle
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.green.shade300,
                      Colors.green.shade500,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Inhale',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        onEnd: () {
          if (mounted && !_isDisposed) {
            setState(() {}); // Restart animation
          }
        },
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
          animation: _animationController!,
          builder: (context, child) {
            final value = _animationController!.value;
            final totalDuration = _getTotalCycleDuration().toDouble();
            final inhaleDuration = selectedExercise!.inhaleTime / totalDuration;
            final holdDuration = selectedExercise!.holdTime / totalDuration;
            final exhaleDuration = selectedExercise!.exhaleTime / totalDuration;
            final holdOutDuration =
                selectedExercise!.holdOutTime / totalDuration;

            double size;
            String phase;

            if (value < inhaleDuration) {
              phase = 'Inhale';
              size = 150 + (value / inhaleDuration) * 100;
            } else if (value < inhaleDuration + holdDuration) {
              phase = 'Hold';
              size = 250;
            } else if (value < inhaleDuration + holdDuration + exhaleDuration) {
              phase = 'Exhale';
              final exhaleProgress =
                  (value - (inhaleDuration + holdDuration)) / exhaleDuration;
              size = 250 - (exhaleProgress * 100);
            } else {
              phase = 'Rest';
              size = 150;
            }

            if (!_isDisposed && mounted) {
              _currentPhase.value = phase;
            }

            return _buildBreathingCircles(size);
          },
        ),
        ValueListenableBuilder<bool>(
          valueListenable: _isPlaying,
          builder: (context, isPlaying, child) {
            if (!isPlaying) return const SizedBox.shrink();
            return _buildMotivationalMessage();
          },
        ),
      ],
    );
  }

  Widget _buildBreathingCircles(double size) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: size + 40,
          height: size + 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
        ),
        _buildMainBreathingCircle(size),
      ],
    );
  }

  Widget _buildMainBreathingCircle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green.shade300,
            Colors.green.shade500,
          ],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Center(
        child: ValueListenableBuilder<String>(
          valueListenable: _currentPhase,
          builder: (context, phase, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  phase,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (_isPlaying.value)
                  Text(
                    '${(_animationController!.value * _getTotalCycleDuration()).toInt()} s',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMotivationalMessage() {
    return Positioned(
      bottom: 20,
      left: 32,
      right: 32,
      child: ValueListenableBuilder<String>(
        valueListenable: _motivationalMessage,
        builder: (context, message, child) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              child: Text(
                message,
                key: ValueKey<String>(message),
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.green[700],
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildControlButton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: ValueListenableBuilder<bool>(
        valueListenable: _isPlaying,
        builder: (context, isPlaying, child) {
          return ElevatedButton(
            onPressed: isPlaying ? _stopExercise : _startExercise,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isPlaying ? Colors.red.shade400 : Colors.green.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 4,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(isPlaying ? Icons.stop : Icons.play_arrow, size: 28),
                const SizedBox(width: 8),
                Text(
                  isPlaying ? 'Stop Exercise' : 'Start Exercise',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBreathingPattern(BreathingExercise exercise) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildPatternStep(
              'Inhale', exercise.inhaleTime, Colors.blue.shade400),
          if (exercise.holdTime > 0)
            _buildPatternStep('Hold', exercise.holdTime, Colors.amber.shade400),
          _buildPatternStep(
              'Exhale', exercise.exhaleTime, Colors.green.shade400),
          if (exercise.holdOutTime > 0)
            _buildPatternStep(
                'Rest', exercise.holdOutTime, Colors.purple.shade400),
        ],
      ),
    );
  }

  Widget _buildPatternStep(String label, int duration, Color color) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: Text(
              '$duration',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    _currentPhase.dispose();
    _isPlaying.dispose();
    _motivationalMessage.dispose();
    _animationController?.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }
}
