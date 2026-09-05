import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/head/head_bloc.dart';
import '../../services/payment_service.dart';

class HeadAttendanceScreen extends StatefulWidget {
  final String? eventId;
  final String? eventTitle;

  const HeadAttendanceScreen({
    super.key,
    this.eventId,
    this.eventTitle,
  });

  @override
  State<HeadAttendanceScreen> createState() => _HeadAttendanceScreenState();
}

class _HeadAttendanceScreenState extends State<HeadAttendanceScreen> {
  final TextEditingController _qrCodeController = TextEditingController();
  final PaymentService _paymentService = PaymentService();
  bool _isProcessing = false;
  Map<String, dynamic>? _lastVerifiedResult;
  String? _errorMessage;

  @override
  void dispose() {
    _qrCodeController.dispose();
    super.dispose();
  }

  Future<void> _handleVerify() async {
    final code = _qrCodeController.text.trim();
    if (code.isEmpty) {
      setState(() => _errorMessage = "Please enter or scan a QR code");
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
      _lastVerifiedResult = null;
    });

    try {
      if (widget.eventId != null && widget.eventId!.isNotEmpty) {
        context.read<HeadBloc>().add(CheckInQrRequested(widget.eventId!, code));
      } else {
        final res = await _paymentService.verifyQrParticipation(code);
        if (mounted) {
          setState(() {
            _lastVerifiedResult = res;
            _isProcessing = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HeadBloc, HeadState>(
      listener: (context, state) {
        if (state is HeadAttendanceSuccess) {
          setState(() {
            _isProcessing = false;
            _lastVerifiedResult = state.participant ?? {'participantName': 'Participant Verified'};
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.green),
          );
        } else if (state is HeadError) {
          setState(() {
            _isProcessing = false;
            _errorMessage = state.message;
          });
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7FA),
        appBar: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor: const Color(0xFF191C32),
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 18,
              child: IconButton(
                iconSize: 18,
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          title: Text(
            widget.eventTitle != null ? "Attendance: ${widget.eventTitle}" : "QR Attendance Check-In",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Scanner / Code Entry Container
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF191C32),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF5FC88F), width: 3),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.qr_code_scanner,
                        size: 60,
                        color: Color(0xFF5FC88F),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "SCAN OR ENTER QR CODE",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Enter the QR ticket string from participant's app",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _qrCodeController,
                    style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: "e.g. QR-65q123... or INT-65...",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () => _qrCodeController.clear(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isProcessing ? null : _handleVerify,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF7931A),
                      minimumSize: const Size.fromHeight(55),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    ),
                    child: _isProcessing
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "CONFIRM ATTENDANCE",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Result Card
            if (_lastVerifiedResult != null)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: const Color(0xFF5FC88F), width: 2),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 3)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.check_circle, color: Color(0xFF5FC88F), size: 28),
                        SizedBox(width: 10),
                        Text(
                          "CHECK-IN SUCCESSFUL",
                          style: TextStyle(
                            color: Color(0xFF5FC88F),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Text(
                      "Name: ${_lastVerifiedResult!['participantName'] ?? _lastVerifiedResult!['name'] ?? 'Registered Student'}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    if (_lastVerifiedResult!['rollNo'] != null || _lastVerifiedResult!['details'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        "Details: ${_lastVerifiedResult!['rollNo'] ?? _lastVerifiedResult!['details']}",
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                    if (_lastVerifiedResult!['attendedAt'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        "Timestamp: ${_lastVerifiedResult!['attendedAt']}",
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),

            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
