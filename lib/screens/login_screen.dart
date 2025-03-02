import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/mock_data_service.dart';
import 'character_creation_screen.dart';
import 'clan_dashboard_screen.dart';
import '../services/game_effects_service.dart';
import 'dart:math';

/// Login Screen of EPIC ADVENTURES!
/// This magical gateway allows users to log in or sign up for the app.
/// With awesome particles and animations, it's the first step in your legendary journey!
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailValid = false;
  String? _errorMessage;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  // Fun particle effects for login button
  final List<Particle> _particles = [];
  final Random _random = Random();
  
  @override
  void initState() {
    super.initState();
    
    // Add a demo account email for easy testing
    _emailController.text = 'choi@familyquest.com';
    _validateEmail(_emailController.text);
    
    // Setup animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.8, curve: Curves.elasticOut),
      ),
    );
    
    // Start the entrance animation
    _animationController.forward();
    
    // Create particle effects
    _generateParticles();
  }
  
  void _generateParticles() {
    for (int i = 0; i < 15; i++) {
      _particles.add(
        Particle(
          position: Offset(_random.nextDouble(), _random.nextDouble()),
          speed: 0.001 + _random.nextDouble() * 0.002,
          color: AppTheme.getRandomColor().withOpacity(0.7),
          size: 5 + _random.nextDouble() * 8,
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _validateEmail(String value) {
    // Simple email validation - improve for production
    setState(() {
      _emailValid = value.isNotEmpty && value.contains('@');
      _errorMessage = null;
    });
  }

  Future<void> _login() async {
    if (!_emailValid) {
      setState(() {
        _errorMessage = 'Please enter a valid email address!';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 1500));
      
      final mockDataService = Provider.of<MockDataService>(context, listen: false);
      final user = await mockDataService.login(_emailController.text);
      
      // Play sound effect
      GameEffectsService().playSound(GameSound.success);

      if (!mounted) return;

      if (user != null) {
        // Existing user found, navigate to dashboard
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => 
              ClanDashboardScreen(character: user),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      } else {
        // New user, navigate to character creation
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => 
              CharacterCreationScreen(userId: 'new_user_${DateTime.now().millisecondsSinceEpoch}'),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Oops! Login failed: $e';
      });
      
      // Play error sound
      GameEffectsService().playSound(GameSound.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        children: [
          // Background particles
          CustomPaint(
            painter: ParticlePainter(_particles),
            child: Container(width: double.infinity, height: double.infinity),
          ),
          
          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.primaryColor.withOpacity(0.15),
                  AppTheme.backgroundColor.withOpacity(0.1),
                ],
              ),
            ),
          ),
          
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32.0),
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App icon/logo
                      Hero(
                        tag: 'app_logo',
                        child: CircleAvatar(
                          radius: 70,
                          backgroundColor: AppTheme.secondaryColor.withOpacity(0.8),
                          child: Icon(
                            Icons.account_balance,
                            size: 70,
                            color: AppTheme.backgroundColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // App title
                      Text(
                        'Family Choi Chronicles',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      
                      // App subtitle
                      Text(
                        'Turn family history into an epic adventure!',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.textColor.withOpacity(0.7),
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 60),
                      
                      // Email field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: _validateEmail,
                        decoration: InputDecoration(
                          labelText: 'Email Address',
                          hintText: 'Enter your email to begin your quest',
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                            borderSide: BorderSide(
                              color: AppTheme.primaryColor.withOpacity(0.5),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                            borderSide: BorderSide(
                              color: AppTheme.primaryColor,
                              width: 2.0,
                            ),
                          ),
                          fillColor: AppTheme.cardColor.withOpacity(0.9),
                          filled: true,
                        ),
                        style: TextStyle(color: AppTheme.textColor),
                      ),
                      const SizedBox(height: 8),
                      
                      // Error message
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: AppTheme.errorColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),
                      
                      // Login button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: AppTheme.cardColor,
                          backgroundColor: _emailValid 
                            ? AppTheme.primaryColor
                            : AppTheme.primaryColor.withOpacity(0.6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32.0,
                            vertical: 16.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          elevation: 5,
                        ),
                        child: Container(
                          width: 200,
                          child: Center(
                            child: _isLoading
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: AppTheme.cardColor,
                                        strokeWidth: 3.0,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Text(
                                      'Starting Quest...',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.play_arrow, size: 28),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Begin Adventure!',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Help text
                      Text(
                        'First time? Enter your email above to create a new character!',
                        style: TextStyle(
                          color: AppTheme.textColor.withOpacity(0.7),
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
        ],
      ),
    );
  }
}

class Particle {
  Offset position;
  double speed;
  Color color;
  double size;
  
  Particle({
    required this.position,
    required this.speed,
    required this.color,
    required this.size,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  
  ParticlePainter(this.particles);
  
  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      // Update position
      particle.position = Offset(
        particle.position.dx,
        (particle.position.dy + particle.speed) % 1.0,
      );
      
      // Draw particle
      final Paint paint = Paint()
        ..color = particle.color
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(
          particle.position.dx * size.width,
          particle.position.dy * size.height,
        ),
        particle.size,
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
} 