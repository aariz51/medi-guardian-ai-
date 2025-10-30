import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/openai_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';

class GeneralHealthCheckupScreen extends StatefulWidget {
  const GeneralHealthCheckupScreen({super.key});

  @override
  State<GeneralHealthCheckupScreen> createState() => _GeneralHealthCheckupScreenState();
}

class _GeneralHealthCheckupScreenState extends State<GeneralHealthCheckupScreen>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      'sender': 'ai',
      'message': 'Hello! I\'m your General Health AI Assistant. I can help you with general health concerns, symptoms analysis, and provide guidance on when to see a doctor. What health concern can I help you with today?',
      'timestamp': DateTime.now(),
    }
  ];
  
  bool _isLoading = false;
  bool _isListening = false;
  bool _isSpeaking = false;
  File? _selectedImage;
  File? _selectedDocument;
  
  // late FlutterTts _flutterTts;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    _initializeTts();
    _initializeAnimations();
  }

  void _initializeTts() {
    // _flutterTts = FlutterTts();
    // _flutterTts.setCompletionHandler(() {
    //   setState(() {
    //     _isSpeaking = false;
    //   });
    // });
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _waveController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_waveController);

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _pulseController.dispose();
    _waveController.dispose();
    // _flutterTts.stop();
    super.dispose();
  }

  Future<void> _sendMessage({String? voiceInput}) async {
    final message = voiceInput ?? _messageController.text.trim();
    if (message.isEmpty || _isLoading) return;

    final userMessage = {
      'sender': 'user',
      'message': message,
      'timestamp': DateTime.now(),
      'image': _selectedImage,
      'document': _selectedDocument,
    };

    setState(() {
      _messages.add(userMessage);
      _messageController.clear();
      _selectedImage = null;
      _selectedDocument = null;
      _isLoading = true;
    });

    try {
      final openAIService = OpenAIService();
      // Fetch user's health profile context from Supabase
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;
      Map<String, dynamic>? profile;
      if (userId != null) {
        try {
          final rows = await supabase.from('user_profiles').select().eq('id', userId).limit(1);
          if (rows is List && rows.isNotEmpty) profile = rows.first as Map<String, dynamic>;
        } catch (_) {}
      }

      final medicalInfo = (profile?['medical_info'] ?? {}) as Map<String, dynamic>;
      final conditions = (medicalInfo['conditions'] ?? []) as List<dynamic>;
      final allergies = (medicalInfo['allergies'] ?? []) as List<dynamic>;

      String prompt = "As a general health AI assistant, provide helpful, safe guidance for this concern: \n$message\n";
      if (conditions.isNotEmpty) {
        prompt += "\nUser known conditions: ${conditions.join(', ')}.";
      }
      if (allergies.isNotEmpty) {
        prompt += "\nUser known allergies: ${allergies.join(', ')}.";
      }
      
      if (userMessage['image'] != null) {
        prompt += "\n\nNote: User has attached an image for context.";
      }
      
      if (userMessage['document'] != null) {
        prompt += "\n\nNote: User has attached a document for context.";
      }
      
      prompt += "\n\nAlways include when to seek urgent care, and remind to consult a clinician. Keep tone clear and empathetic.";
      
      final raw = await openAIService.chatCompletion(prompt);
      final response = _prettify(raw);
      if (!mounted) return;
      setState(() {
        _messages.add({
          'sender': 'ai',
          'message': response,
          'timestamp': DateTime.now(),
          'links': _extractLinks(response),
        });
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add({
          'sender': 'ai',
          'message': 'I apologize, but I\'m having trouble connecting right now. Please check your internet connection and try again.',
          'timestamp': DateTime.now(),
        });
        _isLoading = false;
      });
    }
  }

  Future<void> _startListening() async {
    // Temporarily disabled due to speech_to_text build issues
    setState(() {
      _isListening = true;
    });
    _waveController.repeat();
    
    // Simulate voice input for now
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _messageController.text = "I have a headache and feel tired";
          _isListening = false;
        });
        _waveController.stop();
        _sendMessage(voiceInput: "I have a headache and feel tired");
      }
    });
  }

  void _stopListening() {
    setState(() {
      _isListening = false;
    });
    _waveController.stop();
  }

  Future<void> _speak(String text) async {
    setState(() {
      _isSpeaking = true;
    });
    // await _flutterTts.speak(text);
    // TTS temporarily disabled
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isSpeaking = false;
      });
    });
  }

  Future<void> _showAttachmentOptions() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Text(
                  'Add Attachment',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkBlue,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildAttachmentCard(
                        icon: Icons.camera_alt,
                        label: 'Camera',
                        onTap: () => _pickImage(ImageSource.camera),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildAttachmentCard(
                        icon: Icons.photo_library,
                        label: 'Gallery',
                        onTap: () => _pickImage(ImageSource.gallery),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildAttachmentCard(
                        icon: Icons.description,
                        label: 'Document',
                        onTap: () => _pickDocument(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAttachmentCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.primaryBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.primaryBlue.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: AppTheme.primaryBlue),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.darkBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    Navigator.of(context).pop();
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickDocument() async {
    Navigator.of(context).pop();
    // For now, simulate document picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Document picker coming soon!')),
    );
  }

  Widget _buildMessage(Map<String, dynamic> message, int index) {
    final isUser = message['sender'] == 'user';
    final timestamp = message['timestamp'] as DateTime;
    final image = message['image'] as File?;
    final document = message['document'] as File?;
    
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        child: Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isUser ? AppTheme.primaryBlue : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 8),
                  bottomRight: Radius.circular(isUser ? 8 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (image != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        image,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (document != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.lightBlue.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.description, color: AppTheme.primaryBlue),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Document attached',
                              style: TextStyle(color: AppTheme.primaryBlue),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isUser) ...[
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.health_and_safety,
                            color: AppTheme.primaryGreen,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Text(
                          message['message']!,
                          style: TextStyle(
                            color: isUser ? Colors.white : AppTheme.darkBlue,
                            fontSize: 16,
                            height: 1.4,
                          ),
                        ),
                      ),
                      if (!isUser && !_isSpeaking) ...[
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () => _speak(message['message']!),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              Icons.volume_up,
                              size: 16,
                              color: AppTheme.primaryBlue.withOpacity(0.7),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (!isUser && (message['links'] as List<String>? ?? []).isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: (message['links'] as List<String>)
                          .map((url) => InkWell(
                                onTap: () async {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(url)),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryBlue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    url,
                                    style: const TextStyle(color: AppTheme.primaryBlue, fontSize: 12),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 12, right: 12),
              child: Text(
                _formatTime(timestamp),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  List<String> _extractLinks(String text) {
    final regex = RegExp(r'(https?:\/\/[^\s)]+)');
    return regex.allMatches(text).map((m) => m.group(0)!).toList();
  }

  String _prettify(String text) {
    var t = text.replaceAll(RegExp(r':\s*\n'), '\n');
    t = t.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    return t.trim();
  }

  Widget _buildVoiceRecordingIndicator() {
    return AnimatedBuilder(
      animation: _waveAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.primaryGreen.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Listening...',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.darkBlue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 3,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(1.5),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: _waveAnimation.value,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen,
                            borderRadius: BorderRadius.circular(1.5),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _stopListening,
                icon: const Icon(Icons.stop, color: Colors.red),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'General Health Checkup',
          style: TextStyle(
            color: AppTheme.darkBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.darkBlue),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppTheme.darkBlue),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryGreen.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            if (_isListening) _buildVoiceRecordingIndicator(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _messages.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppTheme.primaryGreen,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'AI is analyzing...',
                                style: TextStyle(
                                  color: AppTheme.darkBlue,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                  
                  return _buildMessage(_messages[index], index);
                },
              ),
            ),
            if (_selectedImage != null || _selectedDocument != null)
              Container(
                margin: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    if (_selectedImage != null) ...[
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _selectedImage!,
                              height: 60,
                              width: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: -8,
                            right: -8,
                            child: IconButton(
                              onPressed: () {
                                setState(() {
                                  _selectedImage = null;
                                });
                              },
                              icon: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                    ],
                    if (_selectedDocument != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.lightBlue.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.description, color: AppTheme.primaryBlue),
                            const SizedBox(width: 8),
                            Text(
                              'Document',
                              style: TextStyle(color: AppTheme.primaryBlue),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _selectedDocument = null;
                                });
                              },
                              icon: const Icon(Icons.close, size: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _showAttachmentOptions,
                      icon: Icon(
                        Icons.attach_file,
                        color: AppTheme.primaryGreen.withOpacity(0.7),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        onSubmitted: (_) => _sendMessage(),
                        maxLines: null,
                        decoration: InputDecoration(
                          hintText: 'Describe your health concern...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: AppTheme.primaryGreen.withOpacity(0.1),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _isListening ? _pulseAnimation.value : 1.0,
                          child: IconButton(
                            onPressed: _isListening ? _stopListening : _startListening,
                            icon: Icon(
                              _isListening ? Icons.mic : Icons.mic_none,
                              color: _isListening ? Colors.red : AppTheme.primaryGreen.withOpacity(0.7),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: _sendMessage,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(
                          Icons.send,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
