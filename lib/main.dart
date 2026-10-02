import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(const FantasyApp());
}

// ================= PLAYER MODEL =================

class Player {
  final String name;
  final String role;
  final String team;
  final double credit;

  bool playing;
  int runs;
  int balls;
  int fours;
  int sixes;
  int wickets;
  int catches;
  

  Player({
    required this.name,
    required this.role,
    required this.team,
    required this.credit,
    this.playing = true,
    this.runs = 0,
    this.balls = 0,
    this.fours = 0,
    this.sixes = 0,
    this.wickets = 0,
    this.catches = 0,
  });

  double get points {
  return runs +
      (fours * 2) +
      (sixes * 4) +
      (wickets * 30) +
      (catches * 10);
}
  }


void updateLiveStats(
  Player player, {
  int? runs,
   int? balls,
  int? fours,
  int? sixes,
  int? wickets,
  int? catches,
}) {
  if (runs != null) player.runs = runs;
  if (balls != null) player.balls = balls;
  if (fours != null) player.fours = fours;
  if (sixes != null) player.sixes = sixes;
  if (wickets != null) player.wickets = wickets;
  if (catches != null) player.catches = catches;
}


// ================= MATCH MODEL =================

class MatchModel {
  final String team1;
  final String team2;
  final String team1Flag;
  final String team2Flag;
  final String title;
  final String time;
final String matchFormat;
String status;
  final int userRank;
  int userPoints;
  final DateTime? startTime;
  final Duration liveDuration;
  final DateTime? completedAt;
  final String? winner;
int? team1Score;
int? team2Score;
  int? team1Wickets;
int? team2Wickets;
  final double entryFee;
final double prizePool;
  final String contestName;
final int contestSpots;
  final String team1Players;
final String team2Players;
  String get currentStatus {
  // Admin ने manually Complete किया है तो हमेशा COMPLETED
  if (status == 'COMPLETED') {
    return 'COMPLETED';
  }

  if (startTime == null) return status;

  final now = DateTime.now();

  if (now.isBefore(startTime!)) {
    return 'UPCOMING';
  }

  if (now.isBefore(startTime!.add(liveDuration))) {
    return 'LIVE';
  }

  return 'COMPLETED';
}

  MatchModel({
    required this.team1,
    required this.team2,
    required this.team1Flag,
    required this.team2Flag,
    required this.title,
    required this.time,
    this.matchFormat = 'T20',
    required this.status,
    required this.userPoints,
    this.startTime,
    required this.liveDuration,
    this.completedAt,
    this.winner,
this.team1Score,
this.team2Score,
   
    required this.userRank,
    this.entryFee = 25,
this.prizePool = 1000,
    this.contestName = 'Default Contest',
this.contestSpots = 3,
    this.team1Players = '',
this.team2Players = '',
  });
}

// ================= PLAYERS =================

final List<Player> players = [
  Player(
    name: 'KL Rahul',
    role: 'WK',
    team: 'IND',
    credit: 8.5,
    runs: 45,
    fours: 5,
    sixes: 1,
    catches: 2,
  ),
  Player(
    name: 'Alex Carey',
    role: 'WK',
    team: 'AUS',
    credit: 8.0,
    runs: 32,
    fours: 4,
    sixes: 1,
    catches: 3,
  ),
  Player(
    name: 'Rohit Sharma',
    role: 'BAT',
    team: 'IND',
    credit: 9.0,
    runs: 72,
    fours: 8,
    sixes: 3,
  ),
  Player(
    name: 'Virat Kohli',
    role: 'BAT',
    team: 'IND',
    credit: 9.5,
    runs: 64,
    fours: 6,
    sixes: 2,
  ),
  Player(
    name: 'Steve Smith',
    role: 'BAT',
    team: 'AUS',
    credit: 9.0,
    runs: 58,
    fours: 5,
    sixes: 1,
  ),
  Player(
    name: 'Travis Head',
    role: 'BAT',
    team: 'AUS',
    credit: 9.0,
    runs: 81,
    fours: 9,
    sixes: 3,
  ),
  Player(
    name: 'Hardik Pandya',
    role: 'AR',
    team: 'IND',
    credit: 9.0,
    runs: 38,
    fours: 3,
    sixes: 2,
    wickets: 2,
  ),
  Player(
    name: 'Ravindra Jadeja',
    role: 'AR',
    team: 'IND',
    credit: 8.5,
    runs: 41,
    fours: 4,
    sixes: 1,
    wickets: 3,
    catches: 1,
  ),
  Player(
    name: 'Glenn Maxwell',
    role: 'AR',
    team: 'AUS',
    credit: 8.5,
    runs: 36,
    fours: 3,
    sixes: 2,
    wickets: 1,
    catches: 2,
  ),
  Player(
    name: 'Jasprit Bumrah',
    role: 'BOWL',
    team: 'IND',
    credit: 9.0,
    wickets: 4,
    catches: 1,
  ),
  Player(
    name: 'Mohammed Siraj',
    role: 'BOWL',
    team: 'IND',
    credit: 8.0,
    wickets: 2,
  ),
  Player(
    name: 'Pat Cummins',
    role: 'BOWL',
    team: 'AUS',
    credit: 8.5,
    wickets: 3,
    catches: 1,
  ),
  Player(
    name: 'Mitchell Starc',
    role: 'BOWL',
    team: 'AUS',
    credit: 8.5,
    wickets: 2,
  ),
  Player(
    name: 'Adam Zampa',
    role: 'BOWL',
    team: 'AUS',
    credit: 8.0,
    wickets: 3,
  ),
];
final List<Player> engSaPlayers = [
  Player(
    name: 'Jos Buttler',
    role: 'WK',
    team: 'ENG',
    credit: 9.0,
    runs: 48,
    fours: 5,
    sixes: 2,
    catches: 2,
  ),
  Player(
    name: 'Quinton de Kock',
    role: 'WK',
    team: 'SA',
    credit: 9.0,
    runs: 54,
    fours: 6,
    sixes: 2,
    catches: 1,
  ),
  Player(
    name: 'Joe Root',
    role: 'BAT',
    team: 'ENG',
    credit: 9.0,
    runs: 67,
    fours: 7,
    sixes: 1,
  ),
  Player(
    name: 'Harry Brook',
    role: 'BAT',
    team: 'ENG',
    credit: 8.5,
    runs: 59,
    fours: 5,
    sixes: 2,
  ),
  Player(
    name: 'Temba Bavuma',
    role: 'BAT',
    team: 'SA',
    credit: 8.5,
    runs: 52,
    fours: 6,
    sixes: 1,
  ),
  Player(
    name: 'Aiden Markram',
    role: 'BAT',
    team: 'SA',
    credit: 9.0,
    runs: 63,
    fours: 5,
    sixes: 3,
  ),
  Player(
    name: 'Ben Stokes',
    role: 'AR',
    team: 'ENG',
    credit: 9.0,
    runs: 42,
    fours: 4,
    sixes: 2,
    wickets: 2,
  ),
  Player(
    name: 'Moeen Ali',
    role: 'AR',
    team: 'ENG',
    credit: 8.0,
    runs: 31,
    fours: 3,
    wickets: 2,
  ),
  Player(
    name: 'Marco Jansen',
    role: 'AR',
    team: 'SA',
    credit: 8.5,
    runs: 29,
    fours: 2,
    sixes: 1,
    wickets: 3,
  ),
  Player(
    name: 'Kagiso Rabada',
    role: 'BOWL',
    team: 'SA',
    credit: 9.0,
    wickets: 4,
    catches: 1,
  ),
  Player(
    name: 'Anrich Nortje',
    role: 'BOWL',
    team: 'SA',
    credit: 8.5,
    wickets: 3,
  ),
  Player(
    name: 'Adil Rashid',
    role: 'BOWL',
    team: 'ENG',
    credit: 8.5,
    wickets: 3,
  ),
  Player(name: 'Mark Wood', role: 'BOWL', team: 'ENG', credit: 8.0, wickets: 2),
  Player(
    name: 'Lungi Ngidi',
    role: 'BOWL',
    team: 'SA',
    credit: 8.0,
    wickets: 2,
  ),
];
final List<Player> wiNzPlayers = [
  Player(
    name: 'Shai Hope',
    role: 'WK',
    team: 'WI',
    credit: 8.5,
    runs: 46,
    fours: 5,
    sixes: 1,
    catches: 2,
  ),
  Player(
    name: 'Devon Conway',
    role: 'WK',
    team: 'NZ',
    credit: 9.0,
    runs: 58,
    fours: 6,
    sixes: 2,
    catches: 1,
  ),
  Player(
    name: 'Brandon King',
    role: 'BAT',
    team: 'WI',
    credit: 8.5,
    runs: 61,
    fours: 7,
    sixes: 2,
  ),
  Player(
    name: 'Nicholas Pooran',
    role: 'BAT',
    team: 'WI',
    credit: 9.0,
    runs: 52,
    fours: 4,
    sixes: 3,
  ),
  Player(
    name: 'Kane Williamson',
    role: 'BAT',
    team: 'NZ',
    credit: 9.0,
    runs: 64,
    fours: 6,
    sixes: 1,
  ),
  Player(
    name: 'Daryl Mitchell',
    role: 'BAT',
    team: 'NZ',
    credit: 8.5,
    runs: 55,
    fours: 5,
    sixes: 2,
  ),
  Player(
    name: 'Jason Holder',
    role: 'AR',
    team: 'WI',
    credit: 8.5,
    runs: 34,
    wickets: 2,
  ),
  Player(
    name: 'Roston Chase',
    role: 'AR',
    team: 'WI',
    credit: 8.0,
    runs: 29,
    wickets: 2,
  ),
  Player(
    name: 'Mitchell Santner',
    role: 'AR',
    team: 'NZ',
    credit: 8.5,
    runs: 31,
    wickets: 3,
  ),
  Player(
    name: 'Trent Boult',
    role: 'BOWL',
    team: 'NZ',
    credit: 9.0,
    wickets: 3,
  ),
  Player(
    name: 'Alzarri Joseph',
    role: 'BOWL',
    team: 'WI',
    credit: 8.5,
    wickets: 3,
  ),
  Player(
    name: 'Lockie Ferguson',
    role: 'BOWL',
    team: 'NZ',
    credit: 8.5,
    wickets: 2,
  ),
  Player(
    name: 'Gudakesh Motie',
    role: 'BOWL',
    team: 'WI',
    credit: 8.0,
    wickets: 2,
  ),
  Player(name: 'Ish Sodhi', role: 'BOWL', team: 'NZ', credit: 8.0, wickets: 2),
];

// ================= MATCHES =================

final List<MatchModel> upcomingMatches = [
  MatchModel(
    team1: 'IND',
    team2: 'AUS',
    team1Flag: '🇮🇳',
    team2Flag: '🇦🇺',
    title: 'India vs Australia',
    time: 'Today, 7:30 PM',
    status: 'UPCOMING',
    startTime: DateTime.now().add(
  const Duration(minutes: 1),
),
liveDuration: const Duration(minutes: 30),

userRank: 2,
    userPoints: 684,
    winner: 'IND',
team1Score: 185,
team2Score: 172,
  ),
  MatchModel(
    team1: 'ENG',
    team2: 'SA',
    team1Flag: '🏴',
    team2Flag: '🇿🇦',
    title: 'England vs South Africa',
    time: 'Tomorrow, 6:00 PM',
    status: 'UPCOMING',
    startTime: DateTime.now().add(
  const Duration(minutes: 60),
      
),
    liveDuration: const Duration(minutes: 60),
    userRank: 2,
    userPoints: 620,
  ),
];

final List<MatchModel> liveMatches = [
  MatchModel(
    team1: 'WI',
    team2: 'NZ',
    team1Flag: '🏝️',
    team2Flag: '🇳🇿',
    title: 'West Indies vs New Zealand',
    time: 'LIVE NOW',
    status: 'LIVE',
    startTime: DateTime.now(),
    liveDuration: const Duration(minutes: 60),
    userRank: 3,
    userPoints: 620,
    team1Score: 120,
team2Score: 110,
  ),
];

final List<MatchModel> completedMatches = [
  MatchModel(
    team1: 'PAK',
    team2: 'SL',
    team1Flag: '🇵🇰',
    team2Flag: '🇱🇰',
    title: 'Pakistan vs Sri Lanka',
    time: 'Completed',
    status: 'COMPLETED',
    userRank: 1,
    userPoints: 620,
    liveDuration: Duration.zero,
    


  ),
];

// JOINED MATCHES
final ValueNotifier<List<MatchModel>> joinedMatches =
    ValueNotifier<List<MatchModel>>([]);
// ================= MY JOINED CONTESTS =================
final ValueNotifier<List<Map<String, dynamic>>> joinedContests =
    ValueNotifier<List<Map<String, dynamic>>>([]);
final ValueNotifier<List<List<Player>>> savedTeams =
    ValueNotifier<List<List<Player>>>([]);
final List<String> savedCaptainNames = [];
final List<String> savedViceCaptainNames = [];
final List<String> savedTeamMatchKeys = [];
final ValueNotifier<Map<String, Map<String, dynamic>>> draftTeams =
    ValueNotifier<Map<String, Map<String, dynamic>>>({});
// ================= APP =================

final ValueNotifier<bool> darkMode = ValueNotifier<bool>(false);
final ValueNotifier<bool> hindiMode =
    ValueNotifier<bool>(false);
final ValueNotifier<double> walletBalance =
    ValueNotifier<double>(0);
final ValueNotifier<bool> welcomeBonusClaimed =
    ValueNotifier<bool>(false);
final ValueNotifier<List<Map<String, dynamic>>> bonusHistory =
    ValueNotifier<List<Map<String, dynamic>>>([]);
final ValueNotifier<Set<String>> claimedWinnings = ValueNotifier<Set<String>>(
  <String>{},
);
final ValueNotifier<int> headToHeadJoined = ValueNotifier<int>(1);
final ValueNotifier<int> megaJoined = ValueNotifier<int>(1250);
final ValueNotifier<int> smallJoined = ValueNotifier<int>(67);
final ValueNotifier<List<Map<String, dynamic>>> transactionHistory =
    ValueNotifier<List<Map<String, dynamic>>>([]);
final ValueNotifier<List<Map<String, dynamic>>> walletRequests =
  
    ValueNotifier<List<Map<String, dynamic>>>([]);
// ============== TRANSACTION NUMBER SYSTEM ==============

int depositTxnSerial = 0;
int withdrawTxnSerial = 0;
int bonusTxnSerial = 0;
int welcomeBonusTxnSerial = 0;
int entryTxnSerial = 0;
int winningTxnSerial = 0;

int transactionSerialYear = DateTime.now().year;

String generateTxnNumber(String type) {
  final now = DateTime.now();

  // New year = all serials restart from 00001
  if (transactionSerialYear != now.year) {
    transactionSerialYear = now.year;

    depositTxnSerial = 0;
    withdrawTxnSerial = 0;
    bonusTxnSerial = 0;
    welcomeBonusTxnSerial = 0;
    entryTxnSerial = 0;
    winningTxnSerial = 0;
  }

  String prefix;
  int serial;

  switch (type.toUpperCase()) {
    case 'DEPOSIT':
      prefix = 'D Txn';
      depositTxnSerial++;
      serial = depositTxnSerial;
      break;

    case 'WITHDRAW':
    case 'WITHDRAWAL':
      prefix = 'W Txn';
      withdrawTxnSerial++;
      serial = withdrawTxnSerial;
      break;
      
      case 'WELCOME_BONUS':
  prefix = 'BNS-W-Txn';
  welcomeBonusTxnSerial++;
  serial = welcomeBonusTxnSerial;
  break;

    case 'BONUS':
      prefix = 'Bns Txn';
      bonusTxnSerial++;
      serial = bonusTxnSerial;
      break;

    case 'ENTRY':
    case 'CONTEST_ENTRY':
      prefix = 'Ent Txn';
      entryTxnSerial++;
      serial = entryTxnSerial;
      break;

    case 'WIN':
    case 'WINNING':
      prefix = 'Win Txn';
      winningTxnSerial++;
      serial = winningTxnSerial;
      break;

    default:
      prefix = 'Txn';
      depositTxnSerial++;
      serial = depositTxnSerial;
  }

  final yy =
      (now.year % 100).toString().padLeft(2, '0');
  final mm =
      now.month.toString().padLeft(2, '0');
  final dd =
      now.day.toString().padLeft(2, '0');

  final serialText =
      serial.toString().padLeft(5, '0');

  return '$prefix-$yy$mm$dd-$serialText';
}

// ================= DEPOSIT PAYMENT SETTINGS =================

final ValueNotifier<String> depositPaymentText =
    ValueNotifier<String>('UPI / Payment ID not set');

final ValueNotifier<String> depositWarningText =
    ValueNotifier<String>(
  '⚠ यहाँ QR Code देखकर ही पेमेंट करें। QR Code बदलते रहते हैं।',
);

final ValueNotifier<String?> depositPaymentImage =
    ValueNotifier<String?>(null);

final ValueNotifier<String?> selectedPaymentScreenshot =
    ValueNotifier<String?>(null);
Future<void> pickImageFromGallery(
  ValueNotifier<String?> target,
) async {
  final picker = ImagePicker();

  final image = await picker.pickImage(
    source: ImageSource.gallery,
    imageQuality: 70,
  );

  if (image == null) return;

  final bytes = await image.readAsBytes();

  final extension =
      image.name.toLowerCase().endsWith('.png') ? 'png' : 'jpeg';

  target.value =
      'data:image/$extension;base64,${base64Encode(bytes)}';
}
final ValueNotifier<bool> hasUnreadNotification =
    ValueNotifier<bool>(false);
final ValueNotifier<List<Map<String, dynamic>>> appNotifications =
    ValueNotifier<List<Map<String, dynamic>>>([]);
void addWalletRequest({
  required String type,
  required double amount,
  String? screenshot,
}) {
  final updated =
      List<Map<String, dynamic>>.from(walletRequests.value);

  updated.add({
  'type': type,
  'amount': amount,
  'status': 'PENDING',
  'createdAt': DateTime.now(),
  'screenshot': screenshot,
});

  walletRequests.value = updated;
}

void giveWelcomeBonusIfNeeded() {
  if (welcomeBonusClaimed.value) return;

  final double amount = welcomeBonusAmount.value;

  // Admin ने Welcome Bonus ₹0 रखा है तो bonus नहीं देना
  if (amount <= 0) {
    welcomeBonusClaimed.value = true;
    return;
  }

  final String txnNumber = generateTxnNumber('WELCOME_BONUS');
  final double oldBalance = walletBalance.value;

  walletBalance.value = oldBalance + amount;

  final updatedHistory =
      List<Map<String, dynamic>>.from(transactionHistory.value);

  final now = DateTime.now();

updatedHistory.add({
  'title': 'Welcome Bonus',
  'subtitle': 'Wallet Balance Bonus',
  'description': 'Welcome Bonus added to wallet',
  'amount': amount,
  'type': 'WELCOME_BONUS',
  'txnNumber': txnNumber,
  'createdAt': now,
  'dateTime':
      '${now.day.toString().padLeft(2, '0')}/'
      '${now.month.toString().padLeft(2, '0')}/'
      '${now.year} '
      '${now.hour.toString().padLeft(2, '0')}:'
      '${now.minute.toString().padLeft(2, '0')}',
});

  transactionHistory.value = updatedHistory;

  welcomeBonusClaimed.value = true;
}

final ValueNotifier<bool> authNavigationBlocked =
    ValueNotifier<bool>(false);

// ================= LOGIN PAGE =================

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final loginController = TextEditingController();
  final passwordController = TextEditingController();

  bool hidePassword = true;
  bool isAdminLogin = false;
  bool isLoading = false;

  @override
  void dispose() {
    loginController.dispose();
    passwordController.dispose();
    super.dispose();
  }
Future<void> _login() async {
  final login = loginController.text.trim();
  final password = passwordController.text.trim();

  if (login.isEmpty || password.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Username / Mobile और Password डालें'),
      ),
    );
    return;
  }

  // Normal User में Email से login नहीं करना है.
  // User = Username / Mobile
  // Admin = Username / Mobile / Email
  if (!isAdminLogin && login.contains('@')) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('User Login में Username या Mobile Number डालें'),
      ),
    );
    return;
  }
authNavigationBlocked.value = true;
  setState(() {
    isLoading = true;
  });

  try {
    String authEmail = login;

    // Username या Mobile आया है तो login_lookup से
    // Firebase वाला registered Email निकालेंगे.
    if (!login.contains('@')) {
      String lookupKey = login.toLowerCase();

      // अगर +91 के साथ 10 digit mobile लिखा है तो +91 हटा दें
      if (lookupKey.startsWith('+91') &&
          lookupKey.length == 13) {
        lookupKey = lookupKey.substring(3);
      }

      final lookupDoc = await FirebaseFirestore.instance
          .collection('login_lookup')
          .doc(lookupKey)
          .get();

      if (!lookupDoc.exists) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Username या Mobile Number नहीं मिला'),
          ),
        );
        return;
      }
final lookupData = lookupDoc.data();

      authEmail =
          (lookupData?['authEmail'] ?? '').toString().trim();

      if (authEmail.isEmpty) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('इस Login ID का Email नहीं मिला'),
          ),
        );
        return;
      }
    }

    final credential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: authEmail,
      password: password,
    );

    final uid = credential.user?.uid;

    if (uid == null) {
      await FirebaseAuth.instance.signOut();
      throw Exception('UID_NOT_FOUND');
    }

    // ADMIN LOGIN की अलग verification
    if (isAdminLogin) {
      final adminDoc = await FirebaseFirestore.instance
          .collection('admins')
          .doc(uid)
          .get();

      final adminData = adminDoc.data();

      final role =
          (adminData?['role'] ?? '').toString().toUpperCase();

      final active = adminData?['active'] == true;

      if (!adminDoc.exists ||
          role != 'ADMIN' ||
          !active) {
        await FirebaseAuth.instance.signOut();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('यह Admin account नहीं है'),
          ),
        );
        return;
      }
    } else {
      // अगर ADMIN ने गलती से User Login use किया
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      final userData = userDoc.data();

      final role =
          (userData?['role'] ?? '').toString().toUpperCase();

      if (role == 'ADMIN') {
        await FirebaseAuth.instance.signOut();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Admin account के लिए Admin Login करें'),
          ),
        );
        return;
      }
    }
// Successful login के बाद कुछ navigate नहीं करना.
    // FantasyApp का authStateChanges अपने-आप MainPage खोलेगा.
  } on FirebaseAuthException catch (e) {
    String message = 'Login failed';

    if (e.code == 'invalid-credential' ||
        e.code == 'wrong-password' ||
        e.code == 'user-not-found') {
      message = 'Login ID या Password गलत है';
    } else if (e.code == 'invalid-email') {
      message = 'सही Login ID डालें';
    } else if (e.code == 'too-many-requests') {
      message =
          'बहुत ज्यादा कोशिश हुई, थोड़ी देर बाद try करें';
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  } on FirebaseException catch (e) {
    if (!mounted) return;

    String message = 'Firebase से Login नहीं हो पाया';

    if (e.code == 'permission-denied') {
      message = 'login_lookup की Firebase permission नहीं मिली';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Login नहीं हो पाया'),
      ),
    );
 } finally {
  authNavigationBlocked.value = false;

  if (mounted) {
    setState(() {
      isLoading = false;
    });
  }
  }
}

String _normalizeRecoveryKey(String value) {
  String key = value.trim().toLowerCase();

  if (key.startsWith('+91') && key.length == 13) {
    key = key.substring(3);
  }

  return key;
}

Future<void> _forgotPassword() async {
  final recoveryController = TextEditingController();

  final String? enteredLogin = await showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        title: const Text(
          'Forgot Password',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: recoveryController,
          autofocus: true,
          decoration: InputDecoration(
            labelText: isAdminLogin
                ? 'Username / Mobile / Email'
                : 'Username / Mobile',
            hintText: 'अपना Login ID डालें',
            prefixIcon: const Icon(Icons.person_search_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final value = recoveryController.text.trim();

              if (value.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('पहले अपना Login ID डालें'),
                  ),
                );
                return;
              }

              Navigator.pop(dialogContext, value);
            },
            child: const Text('Send Reset Link'),
          ),
        ],
      );
    },
  );
if (enteredLogin == null || enteredLogin.isEmpty) {
  recoveryController.dispose();
  return;
}

// पहले वाला dialog पूरी तरह बंद होने दो
await Future<void>.delayed(const Duration(milliseconds: 350));

if (!mounted) {
  recoveryController.dispose();
  return;
}

recoveryController.dispose();
  }

  final String lookupKey =
      _normalizeRecoveryKey(enteredLogin);

  // Normal User को Email से login/reset नहीं देना है.
  if (!isAdminLogin && lookupKey.contains('@')) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'User के लिए Username या Mobile Number डालें',
        ),
      ),
    );
    return;
  }

  try {
    String authEmail = '';

    // Admin Email सीधे Firebase Auth वाला Email हो सकता है.
    if (isAdminLogin && lookupKey.contains('@')) {
      authEmail = lookupKey;
    } else {
      final lookupDoc =
          await FirebaseFirestore.instance
              .collection('login_lookup')
              .doc(lookupKey)
              .get();

      if (!lookupDoc.exists) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'यह Username या Mobile Number नहीं मिला',
            ),
          ),
        );
        return;
      }

      final lookupData = lookupDoc.data();

      authEmail =
          (lookupData?['authEmail'] ?? '')
              .toString()
              .trim();
    }

    if (authEmail.isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'इस account का registered Email नहीं मिला',
          ),
        ),
      );
      return;
    }
await FirebaseAuth.instance.sendPasswordResetEmail(
      email: authEmail,
    );

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.mark_email_read_outlined,
                color: Colors.green,
              ),
              SizedBox(width: 10),
              Text('Reset Link Sent'),
            ],
          ),
          content: const Text(
            'Password reset link आपके registered Email पर भेज दिया गया है।',
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  } on FirebaseAuthException catch (e) {
    if (!mounted) return;

    String message = 'Password reset नहीं हो पाया';

    if (e.code == 'invalid-email') {
      message = 'Registered Email सही नहीं है';
    } else if (e.code == 'too-many-requests') {
      message =
          'बहुत ज्यादा कोशिश हुई है, थोड़ी देर बाद फिर कोशिश करें';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Password reset नहीं हो पाया',
        ),
      ),
    );
  }
}
Future<void> _forgotUsername() async {
  final recoveryController = TextEditingController();

  final String? recoveryId = await showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        title: const Text(
          'Forgot Username',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: recoveryController,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Registered Mobile / Email',
            hintText: 'Mobile Number या Email डालें',
            prefixIcon: const Icon(
              Icons.manage_search,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final value =
                  recoveryController.text.trim();

              if (value.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Registered Mobile या Email डालें',
                    ),
                  ),
                );
                return;
              }

              Navigator.pop(dialogContext, value);
            },
            child: const Text('Find Username'),
          ),
        ],
      );
    },
  );
if (enteredLogin == null || enteredLogin.isEmpty) {
  recoveryController.dispose();
  return;
}

await Future<void>.delayed(const Duration(milliseconds: 350));

if (!mounted) {
  recoveryController.dispose();
  return;
}

recoveryController.dispose();

  final String lookupKey =
      _normalizeRecoveryKey(recoveryId);

  final bool isEmail = lookupKey.contains('@');
  final bool isMobile =
      RegExp(r'^[0-9]{10}$').hasMatch(lookupKey);

  if (!isEmail && !isMobile) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Registered Mobile Number या Email ही डालें',
        ),
      ),
    );
    return;
  }

  try {
    final lookupDoc =
        await FirebaseFirestore.instance
            .collection('login_lookup')
            .doc(lookupKey)
            .get();

    if (!lookupDoc.exists) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'इस Mobile/Email से account नहीं मिला',
          ),
        ),
      );
      return;
    }

    final lookupData = lookupDoc.data();

    final String username =
        (lookupData?['username'] ?? '')
            .toString()
            .trim();

    if (username.isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'इस account के लिए Username recovery setup अभी पूरा नहीं है',
          ),
        ),
      );
      return;
    }

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.person_outline,
                color: Colors.green,
              ),
              SizedBox(width: 10),
              Text('Username Found'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'आपका Username है:',
              ),
              const SizedBox(height: 12),
              SelectableText(
                username,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Username recovery नहीं हो पाई',
        ),
      ),
    );
  }
}

  
@override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF071A2E),
              Color(0xFF0D3C48),
              Color(0xFF146B55),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Background light circles
              Positioned(
                top: 50,
                left: -45,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),

              Positioned(
                top: 120,
                right: -55,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),

              // Cricket ball
              const Positioned(
                top: 150,
                right: 55,
                child: Text(
                  '🔴',
                  style: TextStyle(
                    fontSize: 24,
                  ),
                ),
              ),

              // Cricket bat
              const Positioned(
                top: 165,
                left: 45,
                child: Text(
                  '🏏',
                  style: TextStyle(
                    fontSize: 54,
                  ),
                ),
              ),

              // Running player icon
              Positioned(
                top: 185,
                right: 100,
                child: Icon(
                  Icons.directions_run,
                  size: 48,
                  color: Colors.white.withOpacity(0.22),
                ),
              ),

              // Bottom ground
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: 150,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x001B8C66),
                        Color(0xFF0E513C),
                      ],
                    ),
                  ),
                ),
              ),
SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 38),

                    // App logo circle
                    Container(
                      width: 78,
                      height: 78,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFFFC928),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          '🏏',
                          style: TextStyle(
                            fontSize: 42,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // KhelBaaz title
                    const Text(
                      'KhelBaaz',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: Color(0xFFFFD447),
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      isAdminLogin
                          ? 'ADMIN LOGIN'
                          : 'PLAY • COMPETE • WIN',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                        color: Colors.white70,
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'Build your team, join contests\nand become the next KhelBaaz.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.45,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Login card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(
                        22,
                        26,
                        22,
                        24,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.30),
                            blurRadius: 28,
                            offset: const Offset(0, 14),
                          ),
                        ],
                      ),
child: Column(
                        children: [
                          Text(
                            isAdminLogin
                                ? 'Admin Login'
                                : 'Welcome Back',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF10263B),
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            isAdminLogin
                                ? 'Login to manage KhelBaaz'
                                : 'Login to continue playing',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF73808C),
                            ),
                          ),

                          const SizedBox(height: 28),

                          TextField(
                            controller: loginController,
                            keyboardType:
                                TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: isAdminLogin
                                  ? 'Username / Email'
                                  : 'Username',
                              hintText: 'Enter your username',
                              prefixIcon: const Icon(
                                Icons.person_outline,
                              ),
                              filled: true,
                              fillColor:
                                  const Color(0xFFF3F6F7),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder:
                                  OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Color(0xFFD8E2E5),
                                ),
                              ),
                              focusedBorder:
                                  OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Color(0xFF14866D),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
      const SizedBox(height: 16),

                          TextField(
                            controller: passwordController,
                            obscureText: hidePassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              hintText: 'Enter your password',
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                              ),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    hidePassword =
                                        !hidePassword;
                                  });
                                },
                                icon: Icon(
                                  hidePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                              ),
                              filled: true,
                              fillColor:
                                  const Color(0xFFF3F6F7),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder:
                                  OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Color(0xFFD8E2E5),
                                ),
                              ),
                              focusedBorder:
                                  OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Color(0xFF14866D),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
const SizedBox(height: 10),

                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: _forgotUsername,
                                child: const Text(
                                  'Forgot Username?',
                                ),
                              ),
                              TextButton(
                                onPressed: _forgotPassword,
                                child: const Text(
                                  'Forgot Password?',
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed:
                                  isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(0xFF118267),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                    16,
                                  ),
                                ),
elevation: 3,
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child:
                                          CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'LOGIN',
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight:
                                            FontWeight.w900,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                isAdminLogin =
                                    !isAdminLogin;
                              });
                            },
                            icon: Icon(
                              isAdminLogin
                                  ? Icons.person
                                  : Icons.admin_panel_settings,
                            ),
                            label: Text(
                              isAdminLogin
                                  ? 'User Login'
                                  : 'Admin Login',
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    const Text(
                      'KhelBaaz Fantasy Cricket',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

                          
              


class FantasyApp extends StatelessWidget {
  const FantasyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: darkMode,
      builder: (context, isDark, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Fantasy Cricket',

          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.red,
              brightness: Brightness.light,
            ),
          ),

          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.red,
              brightness: Brightness.dark,
            ),
          ),

          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,

          home: StreamBuilder<User?>(
  stream: FirebaseAuth.instance.authStateChanges(),
  builder: (context, snapshot) {
    return ValueListenableBuilder<bool>(
      valueListenable: authNavigationBlocked,
      builder: (context, blocked, _) {
        if (blocked) {
          return const LoginPage();
        }

        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData) {
          return const MainPage();
        }

        return const LoginPage();
      },
    );
  },
),
        );
      },
    );
  }
}

// ================= MAIN PAGE =================

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

int currentIndex = 0;
bool? isAdmin;

@override
void initState() {
  super.initState();
  _loadLoggedInRole();
}

Future<void> _loadLoggedInRole() async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    if (!mounted) return;

    setState(() {
      isAdmin = false;
    });
    return;
  }

  try {
    final doc = await FirebaseFirestore.instance
        .collection('admins')
        .doc(user.uid)
        .get();

    final data = doc.data();

    final bool adminAccount =
        doc.exists &&
        (data?['role'] ?? '')
                .toString()
                .trim()
                .toUpperCase() ==
            'ADMIN' &&
        data?['active'] == true;

    if (!adminAccount) {
      giveWelcomeBonusIfNeeded();
    }

    if (!mounted) return;

    setState(() {
      isAdmin = adminAccount;
    });
  } catch (e) {
    debugPrint('Role load error: $e');

    if (!mounted) return;

    setState(() {
      isAdmin = false;
    });
  }
}

@override
Widget build(BuildContext context) {
  if (isAdmin == null) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  if (isAdmin == true) {
  return const AdminMainPage();
  }

  final pages = [
  
      const HomePage(),
      const MyContestsPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(index: currentIndex, children: pages),
      bottomNavigationBar: CustomPaint(
  painter: BottomNavCurvePainter(),
  child: NavigationBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        destinations: [
        NavigationDestination(
  icon: Container(
    width: 44,
    height: 44,
    decoration: const BoxDecoration(
      color: Color(0xFFFFCFC8),
      shape: BoxShape.circle,
    ),
    child: const Icon(
      Icons.home_outlined,
      color: Color(0xFFA94C43),
      size: 24,
    ),
  ),
  selectedIcon: Container(
    width: 50,
    height: 50,
    decoration: const BoxDecoration(
      color: Color(0xFFFFA89E),
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 6,
          offset: Offset(0, 3),
        ),
      ],
    ),
    child: const Icon(
      Icons.home,
      color: Color(0xFF9B3F36),
      size: 28,
    ),
  ),
  label: 'Home',
),
          NavigationDestination(
  icon: Transform.translate(
    offset: const Offset(0, -4),
    child: Container(
      width: 60,
height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFFFE3A0),
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFFFFB300),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(
        Icons.emoji_events_outlined,
        color: Color(0xFFFF9800),
        size: 30,
      ),
    ),
  ),

  selectedIcon: Transform.translate(
    offset: const Offset(0, -10),
    child: Container(
       width: 70,
height: 70,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFFFB300),
            Color(0xFFFF8F00),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: const Icon(
        Icons.emoji_events,
        color: Colors.white,
        size: 36,
      ),
    ),
  ),

  label: 'My Contests',
),
      
          NavigationDestination(
  icon: Container(
    width: 44,
    height: 44,
    decoration: const BoxDecoration(
      color: Color(0xFFECCBD5),
      shape: BoxShape.circle,
    ),
    child: const Icon(
      Icons.person_outline,
      color: Color(0xFF9A4B62),
      size: 24,
    ),
  ),
  selectedIcon: Container(
    width: 50,
    height: 50,
    decoration: const BoxDecoration(
      color: Color(0xFFE89BB2),
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 6,
          offset: Offset(0, 3),
        ),
      ],
    ),
    child: const Icon(
      Icons.person,
      color: Color(0xFF8E2047),
      size: 28,
    ),
  ),
  label: 'Profile',
),
        ],
      ),
        ),
    );
  }
}

class AdminMainPage extends StatefulWidget {
  const AdminMainPage({super.key});

  @override
  State<AdminMainPage> createState() => _AdminMainPageState();
}

class _AdminMainPageState extends State<AdminMainPage> {
  int currentIndex = 0;

  final pages = const [
    AdminHomePage(),
    AdminDashboardPage(),
    AdminProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.admin_panel_settings_outlined),
            selectedIcon: Icon(Icons.admin_panel_settings),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F7),
      body: SafeArea(
        child: ValueListenableBuilder<List<Map<String, String>>>(
          valueListenable: adminMatches,
          builder: (context, matches, _) {
            final upcomingCount = matches
                .where(
                  (m) =>
                      (m['status'] ?? '')
                          .toUpperCase() ==
                      'UPCOMING',
                )
                .length;

            final liveCount = matches
                .where(
                  (m) =>
                      (m['status'] ?? '')
                          .toUpperCase() ==
                      'LIVE',
                )
                .length;

            final completedCount = matches
                .where(
                  (m) =>
                      (m['status'] ?? '')
                          .toUpperCase() ==
                      'COMPLETED',
                )
                .length;

            final currentMatches = matches
                .where((m) {
                  final status =
                      (m['status'] ?? '').toUpperCase();

                  return status == 'UPCOMING' ||
                      status == 'LIVE';
                })
                .take(3)
                .toList();

            Widget statCard(
              String title,
              int count,
              IconData icon,
              Color color,
            ) {
              return Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(18),
                    border: Border.all(
                      color: color.withOpacity(0.25),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        icon,
                        color: color,
                        size: 28,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$count',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Admin Home',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Manage KhelBaaz',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius:
                            BorderRadius.circular(20),
                      ),
                      child: Text(
                        'ADMIN',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                Row(
                  children: [
                    statCard(
                      'Upcoming',
                      upcomingCount,
                      Icons.schedule,
                      Colors.orange,
                    ),
                    const SizedBox(width: 10),
                    statCard(
                      'Live',
                      liveCount,
                      Icons.sensors,
                      Colors.green,
                    ),
                    const SizedBox(width: 10),
                    statCard(
                      'Completed',
                      completedCount,
                      Icons.check_circle_outline,
                      Colors.deepPurple,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(18),
                  ),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.sports_cricket,
                        color: Colors.deepOrange,
                      ),
                    ),
                    title: const Text(
                      'Manage Matches',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '${matches.length} total matches',
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const AdminMatchesPage(),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 22),

                const Text(
                  'Current Matches',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                if (currentMatches.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(
                        child: Text(
                          'No live or upcoming matches',
                        ),
                      ),
                    ),
                  ),

                ...currentMatches.map((match) {
                  final team1 =
                      match['team1'] ?? '';
                  final team2 =
                      match['team2'] ?? '';
                  final date =
                      match['date'] ?? '';
                  final time =
                      match['time'] ?? '';
                  final status =
                      (match['status'] ?? '')
                          .toUpperCase();

                  final isLive = status == 'LIVE';

                  return Card(
                    margin:
                        const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isLive
                            ? Colors.green.shade50
                            : Colors.orange.shade50,
                        child: Icon(
                          isLive
                              ? Icons.sensors
                              : Icons.schedule,
                          color: isLive
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                      title: Text(
                        '$team1 vs $team2',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        '$date • $time',
                      ),
                      trailing: Text(
                        status,
                        style: TextStyle(
                          color: isLive
                              ? Colors.green
                              : Colors.deepOrange,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }
}

class AdminProfilePage extends StatelessWidget {
  const AdminProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F7),
      appBar: AppBar(
        title: const Text('Admin Profile'),
      ),
      body: user == null
          ? const Center(
              child: Text('Admin account not found'),
            )
          : FutureBuilder<
              DocumentSnapshot<Map<String, dynamic>>>(
              future: FirebaseFirestore.instance
                  .collection('admins')
                  .doc(user.uid)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final data = snapshot.data?.data();

                final username =
                    (data?['username'] ?? 'Admin')
                        .toString();

                final mobile =
                    (data?['mobile'] ?? '')
                        .toString();

                final email =
                    (data?['email'] ??
                            user.email ??
                            '')
                        .toString();

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding:
                            const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const CircleAvatar(
                              radius: 42,
                              backgroundColor:
                                  Color(0xFFFFE5E5),
                              child: Icon(
                                Icons
                                    .admin_panel_settings,
                                size: 46,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              '@$username',
                              style: const TextStyle(
                                fontSize: 23,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets
                                  .symmetric(
                                horizontal: 12,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    Colors.red.shade50,
                                borderRadius:
                                    BorderRadius.circular(
                                  20,
                                ),
                              ),
                              child: Text(
                                'ADMIN',
                                style: TextStyle(
                                  color:
                                      Colors.red.shade700,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Card(
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(
                              Icons.phone,
                            ),
                            title: const Text(
                              'Mobile Number',
                            ),
                            subtitle: Text(
                              mobile.isEmpty
                                  ? 'Not added'
                                  : mobile,
                            ),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(
                              Icons.email_outlined,
                            ),
                            title:
                                const Text('Email'),
                            subtitle: Text(
                              email.isEmpty
                                  ? 'Not added'
                                  : email,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    OutlinedButton.icon(
                      onPressed: () async {
                        final shouldLogout =
                            await showDialog<bool>(
                          context: context,
                          barrierDismissible: false,
                          builder:
                              (dialogContext) {
                            return AlertDialog(
                              title: const Text(
                                'Logout?',
                              ),
                              content: const Text(
                                'क्या आप Admin account से logout करना चाहते हैं?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(
                                      dialogContext,
                                      false,
                                    );
                                  },
                                  child: const Text(
                                    'नहीं',
                                  ),
                                ),
                                FilledButton.icon(
                                  onPressed: () {
                                    Navigator.pop(
                                      dialogContext,
                                      true,
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.logout,
                                  ),
                                  label: const Text(
                                    'हाँ, Logout',
                                  ),
                                ),
                              ],
                            );
                          },
                        );

                        if (shouldLogout == true) {
                          await FirebaseAuth.instance
                              .signOut();
                        }
                      },
                      icon: const Icon(
                        Icons.logout,
                        color: Colors.red,
                      ),
                      label: const Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}

class BottomNavCurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = const Color(0xFFFFE9E5)
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = const Color(0xFFE7B8AF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final path = Path();

    path.moveTo(0, 18);

    path.lineTo(size.width * 0.34, 18);

    path.cubicTo(
      size.width * 0.40,
      18,
      size.width * 0.42,
      0,
      size.width * 0.50,
      0,
    );

    path.cubicTo(
      size.width * 0.58,
      0,
      size.width * 0.60,
      18,
      size.width * 0.66,
      18,
    );

    path.lineTo(size.width, 18);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, fillPaint);

    final topLine = Path()
      ..moveTo(0, 18)
      ..lineTo(size.width * 0.34, 18)
      ..cubicTo(
        size.width * 0.40,
        18,
        size.width * 0.42,
        0,
        size.width * 0.50,
        0,
      )
      ..cubicTo(
        size.width * 0.58,
        0,
        size.width * 0.60,
        18,
        size.width * 0.66,
        18,
      )
      ..lineTo(size.width, 18);

    canvas.drawPath(topLine, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
final ValueNotifier<List<Map<String, String>>> adminMatches =
    ValueNotifier<List<Map<String, String>>>([]);
final Map<String, Map<String, Map<String, int>>> savedPlayerStats = {};
// ================= HOME PAGE =================

class HomePage extends StatefulWidget {
  
  const HomePage({super.key});
  DateTime _adminDateTime(String date, String time) {
  final months = {
    'jan': 1,
    'feb': 2,
    'mar': 3,
    'apr': 4,
    'may': 5,
    'jun': 6,
    'jul': 7,
    'aug': 8,
    'sep': 9,
    'oct': 10,
    'nov': 11,
    'dec': 12,
  };

  try {
    int day;
int month;
int year;

if (date.contains('/')) {
  final d = date.trim().split('/');
  day = int.parse(d[0]);
  month = int.parse(d[1]);
  year = int.parse(d[2]);
} else {
  final d = date.trim().toLowerCase().split(' ');
  day = int.parse(d[0]);
  month = months[d[1]]!;
  year = int.parse(d[2]);
}

    final t = time.trim().toUpperCase();
    final isPM = t.contains('PM');
    final isAM = t.contains('AM');

    final clean = t
        .replaceAll('AM', '')
        .replaceAll('PM', '')
        .trim();

    final parts = clean.split(':');
    int hour = int.parse(parts[0]);
    final minute =
        parts.length > 1 ? int.parse(parts[1]) : 0;

    if (isPM && hour != 12) hour += 12;
    if (isAM && hour == 12) hour = 0;

    return DateTime(year, month, day, hour, minute);
  } catch (_) {
    return DateTime.now();
  }
}
 
    List<MatchModel> get adminMatchModels {
  return adminMatches.value.map((m) {
    final model = MatchModel(
      team1: m['team1'] ?? '',
      team2: m['team2'] ?? '',
      team1Players: m['team1Players'] ?? '',
team2Players: m['team2Players'] ?? '',
      matchFormat: m['matchFormat'] ?? 'T20',
      team1Flag: (m['team1Logo'] ?? '').isNotEmpty
    ? m['team1Logo']!
    : '🏏',

team2Flag: (m['team2Logo'] ?? '').isNotEmpty
    ? m['team2Logo']!
    : '🏏',
      title: '${m['team1'] ?? ''} vs ${m['team2'] ?? ''}',
      time: '${m['date'] ?? ''} • ${m['time'] ?? ''}',
      status: m['status'] ?? 'UPCOMING',
      startTime: _adminDateTime(
  m['date'] ?? '',
  m['time'] ?? '',
),
      liveDuration: Duration(
  minutes: int.tryParse(m['durationMinutes'] ?? '180') ?? 180,
),
      team1Score: int.tryParse(m['team1Score'] ?? '0') ?? 0,
team2Score: int.tryParse(m['team2Score'] ?? '0') ?? 0,

      userRank: 0,
      userPoints: 0,
    );
    model.team1Wickets =
    int.tryParse(m['team1Wickets'] ?? '0') ?? 0;

model.team2Wickets =
    int.tryParse(m['team2Wickets'] ?? '0') ?? 0;

return model;
  }).toList();
}
  
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedTab = 0;
Timer? homeCountdownTimer;
DateTime now = DateTime.now();
  void _refreshAdminMatches() {
  if (!mounted) return;
  setState(() {});
}
  @override
void initState() {
  super.initState();
adminMatches.addListener(_refreshAdminMatches);
  homeCountdownTimer = Timer.periodic(
    const Duration(seconds: 1),
    (_) {
      if (!mounted) return;

      setState(() {
        now = DateTime.now();
      });
    },
  );
}

@override
void dispose() {
  homeCountdownTimer?.cancel();
  adminMatches.removeListener(_refreshAdminMatches);
  super.dispose();
}
  List<MatchModel> get currentMatches {
  final now = DateTime.now();

  // UPCOMING:
  // जो सबसे जल्दी LIVE होगा वह सबसे ऊपर
  int compareUpcoming(MatchModel a, MatchModel b) {
    final aTime = a.startTime;
    final bTime = b.startTime;

    if (aTime == null && bTime == null) return 0;
    if (aTime == null) return 1;
    if (bTime == null) return -1;

    return aTime.compareTo(bTime);
  }

  // LIVE:
  // जो अभी शुरू हो चुका है वह ऊपर
  // future LIVE वाला नीचे
  int compareLive(MatchModel a, MatchModel b) {
    final aTime = a.startTime;
    final bTime = b.startTime;

    final aStarted =
        aTime != null && !aTime.isAfter(now);
    final bStarted =
        bTime != null && !bTime.isAfter(now);

    if (aStarted != bStarted) {
      return aStarted ? -1 : 1;
    }

    if (aTime == null && bTime == null) return 0;
    if (aTime == null) return 1;
    if (bTime == null) return -1;

    // दोनों LIVE चल रहे हैं:
    // जो हाल में start हुआ वह ऊपर
    if (aStarted && bStarted) {
      return bTime.compareTo(aTime);
    }

    // दोनों future हों तो जो पहले LIVE होगा वह ऊपर
    return aTime.compareTo(bTime);
  }

  bool keepHomeCompleted(MatchModel m) {
    if (m.currentStatus != 'COMPLETED') {
      return false;
    }

    final completionTime =
        m.completedAt ??
        m.startTime?.add(m.liveDuration);

    if (completionTime == null) {
      return true;
    }

    final archiveAt =
    completionTime.add(const Duration(days: 1));

final deleteAt =
    archiveAt.add(const Duration(days: 5));

return DateTime.now().isBefore(deleteAt);
}
  // COMPLETED:
  // latest completed सबसे ऊपर
  int compareCompleted(MatchModel a, MatchModel b) {
    final aTime =
        a.completedAt ??
        a.startTime?.add(a.liveDuration);

    final bTime =
        b.completedAt ??
b.startTime?.add(b.liveDuration);

    if (aTime == null && bTime == null) return 0;
    if (aTime == null) return 1;
    if (bTime == null) return -1;

    return bTime.compareTo(aTime);
  }

  if (selectedTab == 0) {
    final matches = <MatchModel>[
      ...upcomingMatches.where(
        (m) => m.currentStatus == 'UPCOMING',
      ),
      ...widget.adminMatchModels.where(
        (m) => m.currentStatus == 'UPCOMING',
      ),
    ];

    matches.sort(compareUpcoming);
    return matches;
  }

  if (selectedTab == 1) {
    final matches = <MatchModel>[
      ...liveMatches.where(
        (m) => m.currentStatus == 'LIVE',
      ),
      ...upcomingMatches.where(
        (m) => m.currentStatus == 'LIVE',
      ),
      ...widget.adminMatchModels.where(
        (m) => m.currentStatus == 'LIVE',
      ),
    ];

    matches.sort(compareLive);
    return matches;
  }

  final matches = <MatchModel>[
    ...completedMatches.where(keepHomeCompleted),
    ...upcomingMatches.where(keepHomeCompleted),
    ...liveMatches.where(keepHomeCompleted),
    ...widget.adminMatchModels.where(
      keepHomeCompleted,
    ),
  ];

  matches.sort(compareCompleted);
  return matches;
}
  String get heading {
    if (selectedTab == 0) {
      return hindiMode.value ? 'आगामी मैच' : 'Upcoming Matches';
    }
    if (selectedTab == 1) {
      return hindiMode.value ? 'लाइव मैच' : 'Live Matches';
    }
    return hindiMode.value ? 'पूरे हुए मैच' : 'Completed Matches';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
  children: [
    Container(
  width: 48,
  height: 48,
  alignment: Alignment.center,
  decoration: BoxDecoration(
    color: const Color(0xFFE3F2FD),
    borderRadius: BorderRadius.circular(14),
    border: Border.all(
      color: const Color(0xFF1976D2),
      width: 1.2,
    ),
  ),
  child: const Text(
    '🏏',
    style: TextStyle(
      fontSize: 30,
    ),
  ),
),
    const SizedBox(width: 10),
    const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Fantasy Cricket',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Color(0xFF2D2424),
          ),
        ),
        Text(
          'Play • Compete • Win',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Color(0xFFB05A50),
          ),
        ),
      ],
    ),
  ],
),
        actions: [
          IconButton(
            onPressed: () {
              hasUnreadNotification.value = false;
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsPage()),
              );
            },
            icon: ValueListenableBuilder<bool>(
  valueListenable: hasUnreadNotification,
  builder: (context, hasUnread, child) {
    return Container(
  width: 42,
  height: 42,
  decoration: BoxDecoration(
    gradient: const LinearGradient(
      colors: [
        Color(0xFFFFE3EC),
        Color(0xFFFFF0E8),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    shape: BoxShape.circle,
    border: Border.all(
      color: const Color(0xFFE8A5B7),
      width: 1.2,
    ),
    boxShadow: const [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 6,
        offset: Offset(0, 3),
      ),
    ],
  ),
  child: Stack(
    clipBehavior: Clip.none,
    alignment: Alignment.center,
    children: [
      const Text(
  '🔔',
  style: TextStyle(
    fontSize: 25,
  ),
),
      if (hasUnread)
        const Positioned(
          right: 5,
          top: 5,
          child: CircleAvatar(
            radius: 4,
            backgroundColor: Colors.red,
          ),
        ),
    ],
  ),
);
  },
),
            ),
          const SizedBox(width: 6),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(child: tabButton('Upcoming', 0)),
                const SizedBox(
  height: 42,
  child: VerticalDivider(
    width: 6,
    thickness: 1.5,
    color: Color(0xFFD6CACA),
  ),
),
                Expanded(child: tabButton('Live', 1)),
                const SizedBox(
  height: 42,
  child: VerticalDivider(
    width: 6,
    thickness: 1.5,
    color: Color(0xFFD6CACA),
  ),
),
                Expanded(child: tabButton('Completed', 2)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
  backgroundColor: const Color(0xFFE3F2FD),
  foregroundColor: const Color(0xFF1976D2),
  side: const BorderSide(
    color: Color(0xFF64B5F6),
    width: 1.4,
  ),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(24),
  ),
),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MyTeamsPage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.groups),
                        label: const Text('My Teams'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
  child: OutlinedButton.icon(
    style: OutlinedButton.styleFrom(
  backgroundColor: const Color(0xFFE0F2F1),
  foregroundColor: const Color(0xFF00897B),
  side: const BorderSide(
    color: Color(0xFF4DB6AC),
    width: 1.4,
  ),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(24),
  ),
),
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const MyMatchesPage(),
        ),
      );
    },
    icon: const Icon(Icons.emoji_events_outlined),
    label: const Text('My Matches'),
  ),
),
                  ],
                ),
                const SizedBox(height: 12),
                
                  

const SizedBox(height: 12),
                Text(
  heading,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                
                  Container(
  width: double.infinity,
  padding: const EdgeInsets.symmetric(
    horizontal: 18,
    vertical: 10,
  ),
  decoration: BoxDecoration(
    color: const Color(0xFFFFF5F5),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: const Color(0xFFFF8A8A),
      width: 1.4,
    ),
    boxShadow: const [
      BoxShadow(
        color: Color(0x22000000),
        blurRadius: 5,
        offset: Offset(0, 3),
      ),
    ],
  ),
  child: Row(
    children: [
      const Text(
        '🏏',
        style: TextStyle(fontSize: 32),
      ),
      const SizedBox(width: 14),
      Expanded(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose Your Match',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${currentMatches.length} matches available',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF555555),
              ),
            ),
          ],
        ),
      ),
    ],
  ),
),
                const SizedBox(height: 12),
                ...List.generate(currentMatches.length, (index) {
  final match = currentMatches[index];

  if (selectedTab == 1) {
  return MatchCard(match: match);
}

  final matchDate = selectedTab == 0
    ? match.startTime
    : (match.completedAt ??
        match.startTime?.add(match.liveDuration));
  if (matchDate == null) {
    return MatchCard(match: match);
  }

  final previousMatch =
    index > 0 ? currentMatches[index - 1] : null;

final previousDate = previousMatch == null
    ? null
    : selectedTab == 0
        ? previousMatch.startTime
        : (previousMatch.completedAt ??
            previousMatch.startTime?.add(previousMatch.liveDuration));
  final bool newDate =
      previousDate == null ||
      previousDate.year != matchDate.year ||
      previousDate.month != matchDate.month ||
      previousDate.day != matchDate.day;

  final now = DateTime.now();

  final bool isToday =
      now.year == matchDate.year &&
      now.month == matchDate.month &&
      now.day == matchDate.day;

  const months = [
    'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
    'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
  ];

  return Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    
if (newDate)...[
  Padding(
  padding: const EdgeInsets.only(
    top: 10,
    bottom: 10,
  ),
  child: Container(
    width: double.infinity,
    height: 52,
    decoration: BoxDecoration(
      color: selectedTab == 0
          ? const Color(0xFFFFDDE3)
          : const Color(0xFFEDE7FF),
      borderRadius: const BorderRadius.only(
  topLeft: Radius.circular(22),
  topRight: Radius.circular(4),
  bottomLeft: Radius.circular(4),
  bottomRight: Radius.circular(22),
),
    ),
    child: Row(
      children: [
        Container(
          width: 58,
          height: 64,
          decoration: BoxDecoration(
            color: selectedTab == 0
                ? const Color(0xFFE91E3A)
                : const Color(0xFF5E35B1),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(22),
              topRight: Radius.circular(2),
              bottomLeft: Radius.circular(2),
              bottomRight: Radius.circular(22),
            ),
          ),
          child: const Icon(
            Icons.calendar_month_rounded,
            color: Colors.white,
            size: 29,
          ),
        ),
        const SizedBox(width: 10),
        Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isToday
                  ? 'TODAY'
                  : '${matchDate.day} ${months[matchDate.month - 1]}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: selectedTab == 0
                    ? const Color(0xFFC62828)
                    : const Color(0xFF5E35B1),
              ),
            ),
            Text(
              '${matchDate.day} ${months[matchDate.month - 1]} ${matchDate.year}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selectedTab == 0
                    ? const Color(0xFFC62828)
                    : const Color(0xFF5E35B1),
              ),
            ),
          ],
        ),
      ],
    ),
  ),
),
      ],
      MatchCard(match: match),
    ],
  );
}),
      ],
    ),
  ),
],
),
);
  }

  Widget tabButton(String text, int index) {
  final isSelected = selectedTab == index;

  final Color selectedColor = index == 0
      ? const Color(0xFFFF5148) // Upcoming
      : index == 1
          ? const Color(0xFF22A96B) // Live
          : const Color(0xFF6C5CE7); // Completed

  final Color normalColor = index == 0
      ? const Color(0xFFFFDDD9)
      : index == 1
          ? const Color(0xFFDDF3E7)
          : const Color(0xFFEDE9FF);

  final Color normalTextColor = index == 0
      ? const Color(0xFFC64740)
      : index == 1
          ? const Color(0xFF21895B)
          : const Color(0xFF5B4BC4);

  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor:
          isSelected ? selectedColor : normalColor,
      foregroundColor:
          isSelected ? Colors.white : normalTextColor,
      elevation: isSelected ? 3 : 1,
      shape: const BeveledRectangleBorder(
  borderRadius: BorderRadius.all(
    Radius.circular(10),
  ),
),
),
    onPressed: () {
      setState(() {
        selectedTab = index;
      });
    },
    child: Text(text),
  );
}
}

// ================= MATCH CARD =================
class BlinkingLiveText extends StatefulWidget {
  const BlinkingLiveText({super.key});

  @override
  State<BlinkingLiveText> createState() => _BlinkingLiveTextState();
}

class _BlinkingLiveTextState extends State<BlinkingLiveText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: const Text(
        '🔴 LIVE NOW',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.red,
        ),
      ),
    );
  }
}
class MatchCard extends StatelessWidget {
  final MatchModel match;

  const MatchCard({super.key, required this.match});
String shortName(String name) {
  final words = name.trim().split(RegExp(r'\s+'));

  if (words.length == 1) {
    return name.length <= 3
        ? name.toUpperCase()
        : name.substring(0, 3).toUpperCase();
  }

  return words
      .take(3)
      .map((e) => e[0].toUpperCase())
      .join();
}
  @override
  Widget build(BuildContext context) {
    final remaining = match.startTime?.difference(DateTime.now());

final safeRemaining =
    remaining != null && remaining.isNegative
        ? Duration.zero
        : remaining;
    return Card(
  color: match.currentStatus == 'UPCOMING'
      ? const Color(0xFFFFF3E4)
      : match.currentStatus == 'LIVE'
          ? const Color(0xFFEAF8F0)
          : const Color(0xFFF1EEFF),

  elevation: 2,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(18),
    side: const BorderSide(
      color: Color(0xFFF28A8A),
      width: 1.4,
    ),
  ),
  margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) =>
          match.currentStatus == 'LIVE' ||
                  match.currentStatus == 'COMPLETED'
              ? HomePlayerStatsPage(match: match)
              : MatchDetailPage(match: match),
    ),
  );
},
        child: Padding(
  padding: const EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 10,
  ),
          child: Column(
            children: [
    Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [            
    Flexible(
  fit: FlexFit.loose,
  child: Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 10,
      vertical: 7,
    ),
    decoration: BoxDecoration(
      color: match.currentStatus == 'UPCOMING'
          ? const Color(0xFFFFE2C2)
          : match.currentStatus == 'LIVE'
              ? const Color(0xFFDDF3E8)
              : const Color(0xFFE9E5FF),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '${shortName(match.team1)} vs ${shortName(match.team2)} • ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF332626),
            ),
          ),
          TextSpan(
            text: '${match.matchFormat} 🏏',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: match.currentStatus == 'UPCOMING'
                 ? const Color(0xFFD96A18)
                  : match.currentStatus == 'LIVE'
                      ? const Color(0xFF258A64)
                      : const Color(0xFF6753B5),
            ),
          ),
        ],
      ),
    ),
  ),
),
    statusBadge(match.currentStatus),
  ],
),
              
              const Divider(height: 25),
             Row(
  mainAxisAlignment: MainAxisAlignment.spaceAround,
  children: [
    Container(
      width: 92,
      height: 92,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: match.currentStatus == 'LIVE'
            ? const Color(0xFFDDF4E8)
            : match.currentStatus == 'COMPLETED'
                ? const Color(0xFFE9E5FF)
                : const Color(0xFFFFE6DF),
        shape: BoxShape.circle,
        border: Border.all(
          color: match.currentStatus == 'LIVE'
              ? const Color(0xFF71C9A3)
              : match.currentStatus == 'COMPLETED'
                  ? const Color(0xFF9B8AE8)
                  : const Color(0xFFFF9C8D),
          width: 1.4,
        ),
      ),
      child: teamView(match.team1Flag, match.team1),
    ),

    Container(
  width: 64,
  height: 52,
  alignment: Alignment.center,
  decoration: BoxDecoration(
    color: const Color(0xFFFFF1BF),
    borderRadius: BorderRadius.circular(17),
    border: Border.all(
      color: const Color(0xFFFFB300),
      width: 1.7,
    ),
  ),
  child: const Text(
    'VS',
    style: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18,
      color: Color(0xFF8D5A00),
    ),
  ),
),

    Container(
      width: 92,
      height: 92,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: match.currentStatus == 'LIVE'
            ? const Color(0xFFDDF4E8)
            : match.currentStatus == 'COMPLETED'
                ? const Color(0xFFE9E5FF)
                : const Color(0xFFFFE6DF),
        shape: BoxShape.circle,
        border: Border.all(
          color: match.currentStatus == 'LIVE'
              ? const Color(0xFF71C9A3)
              : match.currentStatus == 'COMPLETED'
                  ? const Color(0xFF9B8AE8)
                  : const Color(0xFFFF9C8D),
          width: 1.4,
        ),
      ),
      child: teamView(match.team2Flag, match.team2),
    ),
  ],
), 
              const SizedBox(height: 15),
            
              if (match.currentStatus == 'UPCOMING' && safeRemaining != null)
  Text(
    'Starts in ${safeRemaining.inMinutes.toString().padLeft(2, '0')}:${safeRemaining.inSeconds.remainder(60).toString().padLeft(2, '0')}',
    style: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 15,
    ),
  )
else if (match.currentStatus == 'LIVE')
  Column(
    children: [
      const BlinkingLiveText(),
      const SizedBox(height: 4),
      Text(
        '${shortName(match.team1)} ${match.team1Score ?? 0}/${match.team1Wickets ?? 0}'
'  -  '
'${match.team2Score ?? 0}/${match.team2Wickets ?? 0} ${shortName(match.team2)}',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    ],
  )
              else if (
  match.currentStatus == 'COMPLETED' &&
  
  match.team1Score != null &&
  match.team2Score != null
)
  Column(
  children: [
    Text(
      '${shortName(match.team1)} ${match.team1Score}/${match.team1Wickets ?? 0} - '
      '${match.team2Score}/${match.team2Wickets ?? 0} ${shortName(match.team2)}',
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    ),
    const SizedBox(height: 4),
    Text(
      (match.team1Score ?? 0) > (match.team2Score ?? 0)
          ? 'Winner: ${shortName(match.team1)} 🏆'
          : (match.team2Score ?? 0) > (match.team1Score ?? 0)
              ? 'Winner: ${shortName(match.team2)} 🏆'
              : 'Match Tied',
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.green,
      ),
    ),
  ],
),
            ],
          ),
        ),
      ),
    );
  }

  Widget teamView(String flag, String team) {
  final cleanTeam = team.trim();

  final words = cleanTeam
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .toList();

  String shortName;

  if (words.length >= 2) {
    shortName = words
        .map((word) => word[0].toUpperCase())
        .join();
  } else {
    shortName = cleanTeam.length <= 3
        ? cleanTeam.toUpperCase()
        : cleanTeam.substring(0, 3).toUpperCase();
  }

  return Column(
    children: [
      Text(
        flag,
        style: const TextStyle(fontSize: 35),
      ),
      Text(
        shortName,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );
}

  Widget statusBadge(String status) {
    Color color = const Color(0xFFE85A5A);

    if (status == 'LIVE') {
      color = Colors.red;
    }

    if (status == 'COMPLETED') {
      color = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status == 'UPCOMING'
    ? const Color(0xFFFFD59A)
    : color.withValues(alpha: 0.24),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

class HomePlayerStatsPage extends StatefulWidget {
  final MatchModel match;

  const HomePlayerStatsPage({
    super.key,
    required this.match,
  });

  @override
  State<HomePlayerStatsPage> createState() =>
      _HomePlayerStatsPageState();
}

class _HomePlayerStatsPageState
    extends State<HomePlayerStatsPage> {
  int selectedTeam = 0;
int? expandedPlayerIndex;
  int statValue(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '0') ?? 0;
  }

  String get matchKey {
  final parts = widget.match.time.split('•');

  final oldDate =
      parts.isNotEmpty ? parts[0].trim() : '';

  final oldTime =
      parts.length > 1 ? parts[1].trim() : '';

  final oldKey =
      '${widget.match.team1}_${widget.match.team2}_${oldDate}_$oldTime';

  // Home वाला exact key मिल रहा है तो वही use करो
  if (savedPlayerStats.containsKey(oldKey)) {
    return oldKey;
  }

  // My Matches में पुराना time/date होने पर
  // उसी teams का latest saved stats key लो
  final prefix =
      '${widget.match.team1}_${widget.match.team2}_';

  final keys = savedPlayerStats.keys.toList();

  for (int i = keys.length - 1; i >= 0; i--) {
    final key = keys[i].toString();

    if (key.startsWith(prefix)) {
      return key;
    }
  }

  return oldKey;
}
int totalTeamStat(
  List<String> players,
  Map matchStats,
  String statName,
) {
  int total = 0;

  for (final player in players) {
    final stats = matchStats[player];

    if (stats is Map) {
      total += statValue(stats[statName]);
    }
  }

  return total;
}
  List<String> get team1Players =>
      widget.match.team1Players
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

  List<String> get team2Players =>
      widget.match.team2Players
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

  String playerName(String player) =>
      player.split('|').first.trim();

  String playerRole(String player) {
    final parts = player.split('|');
    return parts.length > 1 ? parts[1].trim() : '';
  }

  Widget statBox(String title, int value) {
    return SizedBox(
      width: 92,
      child: Column(
        children: [
          Text(
            '$value',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
  String shortTeamName(String name) {
  final words = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((e) => e.isNotEmpty)
      .toList();

  if (words.isEmpty) return '';

  if (words.length == 1) {
    final word = words.first.toUpperCase();
    return word.length <= 3 ? word : word.substring(0, 3);
  }

  return words
      .take(3)
      .map((word) => word[0].toUpperCase())
      .join();
}
    @override
  Widget build(BuildContext context) {
    final players =
        selectedTeam == 0 ? team1Players : team2Players;

    final matchStats =
        savedPlayerStats[matchKey] ?? {};
 final team1Runs =
    totalTeamStat(team1Players, matchStats, 'runs');
    final team2Runs =
    totalTeamStat(team2Players, matchStats, 'runs');
final team1Wickets =
    totalTeamStat(team1Players, matchStats, 'wickets');

final team2Wickets =
    totalTeamStat(team2Players, matchStats, 'wickets');
    final latestAdminMatch = adminMatches.value.where(
  (m) =>
      m['team1'] == widget.match.team1 &&
      m['team2'] == widget.match.team2,
).toList();

final bool finalScoreUpdated =
    latestAdminMatch.isNotEmpty &&
    latestAdminMatch.first['finalScoreUpdated'] == 'true';

final String winnerText =
    team1Runs > team2Runs
        ? '${widget.match.team1} WON'
        : team2Runs > team1Runs
            ? '${widget.match.team2} WON'
            : 'MATCH TIED';
    return Scaffold(
  backgroundColor: const Color(0xFFFFF8F6),
      appBar: AppBar(
        title: Text(
  '${widget.match.team1Flag} ${shortTeamName(widget.match.team1)} vs '
'${shortTeamName(widget.match.team2)} ${widget.match.team2Flag} • '
'${widget.match.matchFormat}',
),
      ),
      body: Column(
        children: [
          if (finalScoreUpdated) ...[
  const SizedBox(height: 10),
            const Text(
  '👑',
  style: TextStyle(fontSize: 24),
),
  Text(
    winnerText,
    textAlign: TextAlign.center,
    style: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.green,
    ),
  ),
  const SizedBox(height: 4),
  
  Text(
  '${shortTeamName(widget.match.team1)} '
  '$team1Runs/$team1Wickets'
  '  -  '
  '$team2Runs/$team2Wickets '
  '${shortTeamName(widget.match.team2)}',
  textAlign: TextAlign.center,
  style: const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  ),
),
  const SizedBox(height: 8),
],
   Padding(
  padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
  child: SizedBox(
    height: 126,
    child: Stack(
      children: [

        // ================= TEAM 1 + TEAM 2 =================
        Row(
          children: [

            // ================= TEAM 1 =================
            Expanded(
              child: InkWell(
                onTap: () {
                  setState(() => selectedTeam = 0);
                },
                child: Container(
                  height: 126,
                  decoration: BoxDecoration(
                    color: selectedTeam == 0
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFFFF8F6),

                    border: selectedTeam == 0
                        ? null
                        : Border.all(
                            color: Colors.grey,
                            width: 1,
                          ),

                    borderRadius: selectedTeam == 0
                        ? const BorderRadius.only(
                            topLeft: Radius.circular(18),
                            topRight: Radius.circular(18),
                          )
                        : BorderRadius.circular(18),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.match.team1Flag,
                            style: const TextStyle(
                              fontSize: 30,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$team1Runs/$team1Wickets',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      Text(
                        '${shortTeamName(widget.match.team1)} • '
                        '${widget.match.matchFormat}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),  
           // ================= TEAM 2 =================
            Expanded(
              child: InkWell(
                onTap: () {
                  setState(() => selectedTeam = 1);
                },
                child: Container(
                  height: 126,
                  decoration: BoxDecoration(
                    color: selectedTeam == 1
                        ? const Color(0xFFFFE4E8)
                        : const Color(0xFFFFF8F6),

                    border: selectedTeam == 1
                        ? null
                        : Border.all(
                            color: Colors.grey,
                            width: 1,
                          ),

                    borderRadius: selectedTeam == 1
                        ? const BorderRadius.only(
                            topLeft: Radius.circular(18),
                            topRight: Radius.circular(18),
                          )
                        : BorderRadius.circular(18),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.match.team2Flag,
                            style: const TextStyle(
                              fontSize: 30,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$team2Runs/$team2Wickets',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      Text(
                        '${shortTeamName(widget.match.team2)} • '
                        '${widget.match.matchFormat}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        // ===== EXACT CONNECTED / ROUND BORDER =====
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _TeamHeaderBorderPainter(
                selectedTeam: selectedTeam,
              ),
            ),
          ),
        ),
      ],
    ),
  ),
),     
          
                
                
Expanded(
  child: Container(
    margin: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: selectedTeam == 0
          ? const Color(0xFFE8F5E9)
          : const Color(0xFFFFE4E8),
      border: Border(
        left: BorderSide(
          color: selectedTeam == 0
              ? const Color(0xFF43A047)
              : const Color(0xFFE85D6A),
          width: 2,
        ),
        right: BorderSide(
          color: selectedTeam == 0
              ? const Color(0xFF43A047)
              : const Color(0xFFE85D6A),
          width: 2,
        ),
        bottom: BorderSide(
          color: selectedTeam == 0
              ? const Color(0xFF43A047)
              : const Color(0xFFE85D6A),
          width: 2,
        ),
      ),
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(18),
        bottomRight: Radius.circular(18),
      ),
    ),
    child: ListView.builder(
    itemCount: players.length,
    itemBuilder: (context, index) {
      final player = players[index];
      final stats = matchStats[player] ?? {};

      return Card(
  margin: const EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 5,
  ),
  elevation: 0,
  color: selectedTeam == 0
    ? const Color(0xFFE8F5E9)   // Team 1 Green
    : const Color(0xFFFFE4E8),  // Team 2 Pink
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(14),
    side: BorderSide(
      color: selectedTeam == 0
    ? const Color(0xFF66BB6A)
    : const Color(0xFFE85D6A),
      width: 1,
    ),
  ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               InkWell(
  onTap: () {
    setState(() {
      expandedPlayerIndex =
          expandedPlayerIndex == index ? null : index;
    });
  },
  child: Row(
    children: [
      CircleAvatar(
        radius: 22,
        backgroundColor: selectedTeam == 0
    ? const Color(0xFF2E9B46)
    : const Color(0xFFE5395A),
        child: const Icon(
          Icons.sports_cricket,
          color: Colors.white,
          size: 24,
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              playerName(player),
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              playerRole(player),
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
      Icon(
        expandedPlayerIndex == index
            ? Icons.keyboard_arrow_down
            : Icons.chevron_right,
        color: Colors.grey.shade700,
      ),
    ],
  ),
),
              if (expandedPlayerIndex == index) ...[
  const SizedBox(height: 12),
  Wrap(
                spacing: 8,
                runSpacing: 12,
                children: [
                                    statBox(
                    'Runs',
                    statValue(stats['runs']),
                  ),
                  statBox(
                    'Balls',
                    statValue(stats['balls']),
                  ),
                  statBox(
                    '4s',
                    statValue(stats['fours']),
                  ),
                  statBox(
                    '6s',
                    statValue(stats['sixes']),
                  ),
                  statBox(
                    'Wickets',
                    statValue(stats['wickets']),
                  ),
                  statBox(
                    'Catches',
                    statValue(stats['catches']),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
);
    },
  ),
),
  ),
],
),
);
}
}
class _TeamHeaderBorderPainter extends CustomPainter {
  final int selectedTeam;

  _TeamHeaderBorderPainter({
    required this.selectedTeam,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final color = selectedTeam == 0
        ? const Color(0xFF43A047)
        : const Color(0xFFE85D6A);

    const strokeWidth = 2.5;
    const radius = 18.0;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final double middle = size.width / 2;
    final double bottom = size.height - (strokeWidth / 2);

    final path = Path();

    if (selectedTeam == 0) {
      // TEAM 1 SELECTED
      path.moveTo(strokeWidth / 2, bottom);

      path.lineTo(strokeWidth / 2, radius);

      path.quadraticBezierTo(
        strokeWidth / 2,
        strokeWidth / 2,
        radius,
        strokeWidth / 2,
      );

      path.lineTo(
        middle - radius,
        strokeWidth / 2,
      );

      path.quadraticBezierTo(
        middle,
        strokeWidth / 2,
        middle,
        radius,
      );

      path.lineTo(
        middle,
        bottom - radius,
      );

      // Inner round corner
      path.quadraticBezierTo(
        middle,
        bottom,
        middle + radius,
        bottom,
      );

      // Straight line under TEAM 2
      path.lineTo(
        size.width - (strokeWidth / 2),
        bottom,
      );
    } else {
      // TEAM 2 SELECTED
      path.moveTo(
        size.width - (strokeWidth / 2),
        bottom,
      );

      path.lineTo(
        size.width - (strokeWidth / 2),
        radius,
      );

      path.quadraticBezierTo(
        size.width - (strokeWidth / 2),
        strokeWidth / 2,
        size.width - radius,
        strokeWidth / 2,
      );

      path.lineTo(
        middle + radius,
        strokeWidth / 2,
      );

      path.quadraticBezierTo(
        middle,
        strokeWidth / 2,
        middle,
        radius,
      );

      path.lineTo(
        middle,
        bottom - radius,
      );

      // Inner round corner
      path.quadraticBezierTo(
        middle,
        bottom,
        middle - radius,
        bottom,
      );

      // Straight line under TEAM 1
      path.lineTo(
        strokeWidth / 2,
        bottom,
      );
    }

    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(
    covariant _TeamHeaderBorderPainter oldDelegate,
  ) {
    return oldDelegate.selectedTeam != selectedTeam;
  }
}
  
// ================= MATCH DETAILS =================
final DateTime demoMatchStartTime =
    DateTime.now().add(const Duration(minutes: 30));
class MatchDetailPage extends StatefulWidget {
  final MatchModel match;

  const MatchDetailPage({super.key, required this.match});

  @override
  State<MatchDetailPage> createState() => _MatchDetailPageState();
}

class _MatchDetailPageState extends State<MatchDetailPage> {
  final List<Player> selected = [];
Timer? liveTimer;
  int liveTicks = 0;
  Timer? countdownTimer;
Duration countdown = Duration.zero;
  bool showLiveDot = true;
Timer? blinkTimer;
  bool winningClaimed = false;
  

void autoCreditWinning() {
  // OLD flat winning system disabled.
  // Contest-wise winning is handled in MyMatchDetailPage.
}

  int get team1LiveScore {
  int total = 0;
  final stats = savedPlayerStats[currentMatchKey] ?? {};

  for (final entry in stats.entries) {
    final playerName = entry.key.split('|').first.trim();

    if (widget.match.team1Players
        .split(',')
        .any((p) => p.split('|').first.trim() == playerName)) {
      total += entry.value['runs'] ?? 0;
    }
  }

  return total;
}

int get team2LiveScore {
  int total = 0;
  final stats = savedPlayerStats[currentMatchKey] ?? {};

  for (final entry in stats.entries) {
    final playerName = entry.key.split('|').first.trim();

    if (widget.match.team2Players
        .split(',')
        .any((p) => p.split('|').first.trim() == playerName)) {
      total += entry.value['runs'] ?? 0;
    }
  }

  return total;
}
  int get team1Wickets {
  int total = 0;
  final stats = savedPlayerStats[currentMatchKey] ?? {};

  for (final entry in stats.entries) {
    final playerName = entry.key.split('|').first.trim();

    if (widget.match.team1Players
        .split(',')
        .any((p) => p.split('|').first.trim() == playerName)) {
      total += entry.value['wickets'] ?? 0;
    }
  }

  return total;
}

int get team2Wickets {
  int total = 0;
  final stats = savedPlayerStats[currentMatchKey] ?? {};

  for (final entry in stats.entries) {
    final playerName = entry.key.split('|').first.trim();

    if (widget.match.team2Players
        .split(',')
        .any((p) => p.split('|').first.trim() == playerName)) {
      total += entry.value['wickets'] ?? 0;
    }
  }

  return total;
}
  String get currentMatchKey {
  final parts = widget.match.time.split(' • ');

  final date = parts.isNotEmpty ? parts[0].trim() : '';
  final time = parts.length > 1 ? parts[1].trim() : '';

  return '${widget.match.team1}_${widget.match.team2}_${date}_$time';
}
double get liveTeamPoints {
  final matchingContests = joinedContests.value.where((contest) {
    return contest['team1'] == widget.match.team1 &&
        contest['team2'] == widget.match.team2 &&
        contest['contestName'] == widget.match.contestName;
  }).toList();

  // Contest join ही नहीं किया
  if (matchingContests.isEmpty) {
    return 0;
  }

  final contest = matchingContests.first;

  final rawPlayers = contest['selectedPlayers'];

  final List<Player> myPlayers =
      rawPlayers is List
          ? rawPlayers.whereType<Player>().toList()
          : <Player>[];

  if (myPlayers.isEmpty) {
    return 0;
  }

  final String captainName =
      contest['captainName']?.toString() ?? '';

  final String viceCaptainName =
      contest['viceCaptainName']?.toString() ?? '';

  final matchStats =
      savedPlayerStats[currentMatchKey] ?? {};

  int statValue(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  double total = 0;

  for (final player in myPlayers) {
    String playerKey = '';

    for (final key in matchStats.keys) {
      if (key.split('|').first.trim() ==
          player.name.trim()) {
        playerKey = key;
        break;
      }
    }

    if (playerKey.isEmpty) {
      continue;
    }

    final stats = matchStats[playerKey]!;

    final runs = statValue(stats['runs']);
    final fours = statValue(stats['fours']);
    final sixes = statValue(stats['sixes']);
    final wickets = statValue(stats['wickets']);
    final catches = statValue(stats['catches']);

    final double basePoints =
        runs +
        (fours * 2) +
        (sixes * 4) +
        (wickets * 30) +
        (catches * 10);

    double multiplier = 1;

    if (player.name == captainName) {
      multiplier = 2;
    } else if (player.name == viceCaptainName) {
      multiplier = 1.5;
    }

    total += basePoints * multiplier;
  }

  return total;
}
  bool get hasJoinedContest {
  return joinedContests.value.any((contest) =>
      contest['team1'] == widget.match.team1 &&
      contest['team2'] == widget.match.team2 &&
      contest['contestName'] == widget.match.contestName);
}
 int get liveRank {
  final matchStats =
      savedPlayerStats[currentMatchKey] ?? {};

  final bool hasActualStats =
      matchStats.values.any((stats) {
    return (stats['runs'] ?? 0) > 0 ||
        (stats['fours'] ?? 0) > 0 ||
        (stats['sixes'] ?? 0) > 0 ||
        (stats['wickets'] ?? 0) > 0 ||
        (stats['catches'] ?? 0) > 0;
  });

  if (!hasActualStats) {
    return 0;
  }

  final sameContestUsers =
      joinedContests.value.where((contest) {
    return contest['team1'] == widget.match.team1 &&
        contest['team2'] == widget.match.team2 &&
        contest['contestName'] ==
            widget.match.contestName;
  }).toList();

  if (sameContestUsers.isEmpty) {
    return 0;
  }

  int statValue(dynamic value) {
    if (value is int) return value;
    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  double calculateContestPoints(
      Map<String, dynamic> contest) {
    final rawPlayers =
        contest['selectedPlayers'];

    final List<Player> contestPlayers =
        rawPlayers is List
            ? rawPlayers
                .whereType<Player>()
                .toList()
            : <Player>[];

    if (contestPlayers.isEmpty) {
      return (contest['userPoints'] as num?)
              ?.toDouble() ??
          0;
    }

    final captainName =
        contest['captainName']
                ?.toString() ??
            '';
    

    final viceCaptainName =
        contest['viceCaptainName']
                ?.toString() ??
            '';
      double total = 0;

    for (final player in contestPlayers) {
      String playerKey = '';

      for (final key in matchStats.keys) {
        if (key.split('|').first.trim() ==
            player.name.trim()) {
          playerKey = key;
          break;
        }
      }

      if (playerKey.isEmpty) continue;

      final stats =
          matchStats[playerKey]!;

      final runs =
          statValue(stats['runs']);
      final fours =
          statValue(stats['fours']);
      final sixes =
          statValue(stats['sixes']);
      final wickets =
          statValue(stats['wickets']);
      final catches =
          statValue(stats['catches']);

      final double basePoints =
          runs +
          (fours * 2) +
          (sixes * 4) +
          (wickets * 30) +
          (catches * 10);

      double multiplier = 1;

      if (player.name == captainName) {
        multiplier = 2;
      } else if (
          player.name == viceCaptainName) {
        multiplier = 1.5;
      }

      total +=
          basePoints * multiplier;
    }

    return total;
  }

  final double myPoints =
      liveTeamPoints;

  int rank = 1;

  for (final contest
      in sameContestUsers) {
    if (contest['userId'] == 'user1') {
      continue;
    }

    final double opponentPoints =
        calculateContestPoints(contest);

    if (opponentPoints > myPoints) {
      rank++;
    }
  }

  return rank;
}

@override
void initState() {
  super.initState();
  showDraftOnEntry =
    draftTeams.value.containsKey(currentAdminMatchKey);
  blinkTimer = Timer.periodic(
  const Duration(milliseconds: 500),
  (_) {
    if (!mounted) return;

    setState(() {
      showLiveDot = !showLiveDot;
    });
  },
);
if (widget.match.currentStatus == 'UPCOMING') {
  countdown =
    widget.match.startTime!.difference(DateTime.now());

  countdownTimer = Timer.periodic(
    const Duration(seconds: 1),
    (timer) {
     final remaining =
    widget.match.startTime!.difference(DateTime.now());

      if (!mounted) return;

setState(() {
  countdown =
      remaining.isNegative ? Duration.zero : remaining;
});

if (widget.match.currentStatus == 'COMPLETED') {
  timer.cancel();
}
    },
  );
}

}

@override
void dispose() {
  liveTimer?.cancel();
  countdownTimer?.cancel();
  blinkTimer?.cancel();
  super.dispose();
}
  int _statValue(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

String get currentAdminMatchKey {
  final parts = widget.match.time.split('•');

  final date =
      parts.isNotEmpty ? parts[0].trim() : '';

  final time =
      parts.length > 1 ? parts[1].trim() : '';

  return '${widget.match.team1}_${widget.match.team2}_${date}_$time';
}

int get adminTeam1Score {
  final matchStats =
      savedPlayerStats[currentAdminMatchKey] ?? {};

  final players = widget.match.team1Players
      .split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty);

  return players.fold<int>(0, (total, player) {
    return total +
        _statValue(matchStats[player]?['runs']);
  });
}

int get adminTeam2Score {
  final matchStats =
      savedPlayerStats[currentAdminMatchKey] ?? {};

  final players = widget.match.team2Players
      .split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty);

  return players.fold<int>(0, (total, player) {
    return total +
        _statValue(matchStats[player]?['runs']);
  });
}
  List<Player> get matchPlayers {
  final team1Names = widget.match.team1Players
      .split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  final team2Names = widget.match.team2Players
      .split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  Player makeAdminPlayer(String text, String team) {
  final parts = text.split('|');

  final playerName = parts[0].trim();

  final playerRole = parts.length > 1
      ? parts[1].trim().toUpperCase()
      : 'BAT';

  return Player(
    name: playerName,
    role: playerRole,
    team: team,
    credit: 8.5,
  );
}

final adminPlayers = <Player>[
  ...team1Names.map(
    (text) => makeAdminPlayer(
      text,
      widget.match.team1,
    ),
  ),

  ...team2Names.map(
    (text) => makeAdminPlayer(
      text,
      widget.match.team2,
    ),
  ),
];

  if (adminPlayers.isNotEmpty) {
    return adminPlayers;
  }

  if (widget.match.team1 == 'ENG' &&
      widget.match.team2 == 'SA') {
    return engSaPlayers;
  }

  if (widget.match.team1 == 'WI' &&
      widget.match.team2 == 'NZ') {
    return wiNzPlayers;
  }

  return players;
}

  Player? captain;
  Player? viceCaptain;
  bool teamSaved = false;
bool showDraftOnEntry = false;
  void createTeam() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TeamPage(
          players: matchPlayers,
          selected: selected,
          initialCaptain: captain,
initialViceCaptain: viceCaptain,
          onSave: (c, vc) {
  setState(() {
    captain = c;
    viceCaptain = vc;
    teamSaved = true;
  });

  final drafts =
      Map<String, Map<String, dynamic>>.from(draftTeams.value);

  drafts[currentAdminMatchKey] = {
    'players': List<Player>.from(selected),
    'captain': c,
    'viceCaptain': vc,
  };

  draftTeams.value = drafts;

  Navigator.pop(context);
},
        ),
      ),
    );
  }

  void previewTeam() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TeamPreviewPage(
          selected: selected,
          captain: captain,
          viceCaptain: viceCaptain,
          matchKey: currentAdminMatchKey,
        ),
      ),
    );
  }

  void openContests() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ContestPage(
          teamSaved: teamSaved,
          captain: captain,
          viceCaptain: viceCaptain,
          selected: selected,
          match: widget.match,
          matchKey: currentAdminMatchKey,
        ),
      ),
    );
  }
String _shortTeamName(String name) {
  final words = name.trim().split(RegExp(r'\s+'));

  if (words.length == 1) {
    return name.length <= 3
        ? name.toUpperCase()
        : name.substring(0, 3).toUpperCase();
  }

  return words
      .where((word) => word.isNotEmpty)
      .map((word) => word[0].toUpperCase())
      .join();
}
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
  backgroundColor: const Color(0xFF2563EB),
  foregroundColor: Colors.white,
  title: Text(
  '${widget.match.team1Flag} ${_shortTeamName(widget.match.team1)} vs '
  '${_shortTeamName(widget.match.team2)} ${widget.match.team2Flag} • '
  '${widget.match.matchFormat}',
  style: const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 18,
  ),
),
    
),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
  color: const Color(0xFFFFF4F2),
  elevation: 1.5,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(18),
    side: const BorderSide(
      color: Color(0xFFE85D5D),
      width: 1.4,
    ),
  ),
  child: Padding(
    padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                     '${widget.match.team1Flag} '
'${_shortTeamName(widget.match.team1)} VS '
'${_shortTeamName(widget.match.team2)} '
'${widget.match.team2Flag}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (widget.match.currentStatus == 'LIVE' ||
    widget.match.currentStatus == 'COMPLETED') ...[
  Text(
  '${_shortTeamName(widget.match.team1)} $team1LiveScore/$team1Wickets'
  '  vs  '
  '$team2LiveScore/$team2Wickets ${_shortTeamName(widget.match.team2)}',
    style: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.green,
    ),
  ),
  const SizedBox(height: 8),
],
                  Text(widget.match.title),
                  if (widget.match.currentStatus != 'COMPLETED')
  Text(
    widget.match.time,
    style: const TextStyle(
      fontWeight: FontWeight.bold,
    ),
  ),
                  
                  if (widget.match.currentStatus == 'UPCOMING')
  Text(
    'Starts in '
    '${countdown.inMinutes.remainder(60).toString().padLeft(2, '0')}:'
    '${countdown.inSeconds.remainder(60).toString().padLeft(2, '0')}',
    style: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
    ),
  )
else if (widget.match.currentStatus == 'LIVE')
  BlinkingLiveText()
else if (widget.match.currentStatus == 'COMPLETED')
  const Text(
    'Completed',
    style: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
      color: Colors.green,
    ),
  ),
     ],        
              ),
            ),
          ),
          const SizedBox(height: 15),
          if (widget.match.currentStatus == 'LIVE' ||
    widget.match.currentStatus == 'COMPLETED') ...[
  const SizedBox(height: 15),
  
    if (widget.match.currentStatus == 'COMPLETED') ...[
  const SizedBox(height: 15),
  Text(
  team1LiveScore == 0 && team2LiveScore == 0
      ? 'Result Pending'
      : team1LiveScore > team2LiveScore
          ? '🏆 Winner: ${widget.match.team1}'
          : team2LiveScore > team1LiveScore
              ? '🏆 Winner: ${widget.match.team2}'
              : 'Match Tied',
  style: const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.green,
  ),
),
],
            if (hasJoinedContest)
  Text(
    'Fantasy Points: ${liveTeamPoints.toStringAsFixed(0)}',
    style: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 17,
    ),
  ),
  const SizedBox(height: 5),
  
],
          if (widget.match.currentStatus == 'COMPLETED' &&
    hasJoinedContest) ...[
  const SizedBox(height: 12),
            Text(
  liveRank == 0
      ? 'Rank Pending'
      : 'Your Rank: #$liveRank',
              style: const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 17,
    color: Colors.green,
  ),
),


],
          
          if (widget.match.currentStatus == 'UPCOMING' && !teamSaved)
  Card(
    color: const Color(0xFFFFF4F4),
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
      side: const BorderSide(
        color: Color(0xFFE85D5D),
        width: 1.2,
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: createTeam,
              icon: const Icon(Icons.group_add),
              label: const Text(
                'CREATE TEAM',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: openContests,
              icon: const Icon(Icons.emoji_events),
              label: const Text(
                'VIEW CONTESTS',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE85D5D),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  ),
ValueListenableBuilder<Map<String, Map<String, dynamic>>>(
  valueListenable: draftTeams,
  builder: (context, drafts, _) {
    final hasDraft =
        drafts.containsKey(currentAdminMatchKey);

    if (!showDraftOnEntry || !hasDraft) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Center(
        child: FractionallySizedBox(
          widthFactor: 0.72,
          child: ElevatedButton(
            onPressed: () {
              final draft =
                  drafts[currentAdminMatchKey];

              if (draft == null) return;

              final draftPlayers =
                  List<Player>.from(
                draft['players'] as List<Player>,
              );

              setState(() {
                selected
                  ..clear()
                  ..addAll(draftPlayers);

                captain =
                    draft['captain'] as Player?;

                viceCaptain =
                    draft['viceCaptain'] as Player?;

                teamSaved = true;
                showDraftOnEntry = false;
              });
            },

            style: ElevatedButton.styleFrom(
              backgroundColor:
                  const Color(0xFF7E57C2),

              foregroundColor: Colors.white,

              side: const BorderSide(
                color: Color(0xFF5E35B1),
                width: 1.8,
              ),

              padding: const EdgeInsets.symmetric(
                vertical: 15,
              ),

              elevation: 2,

              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(30),
                ),
              ),
            ),

            child: const Text(
              'DRAFT TEAM',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  },
),          
           
          if (teamSaved) Card(
  color: const Color(0xFFF0FFF4),
  elevation: 2,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(14),
    side: const BorderSide(
      color: Color(0xFFB7E4C7),
      width: 1,
    ),
  ),
            child: Padding(
  padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 8),
                        Text(
                          'Team Created',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text('Captain: ${captain?.name ?? 'Not Selected'}'),
Text('Vice Captain: ${viceCaptain?.name ?? 'Not Selected'}'),
                    const SizedBox(height: 10),
                    
                    const SizedBox(height: 10),
const SizedBox(height: 10),

Row(
  children: [
    Expanded(
      child: ElevatedButton.icon(
        onPressed: createTeam,
        icon: const Icon(
          Icons.edit_outlined,
          size: 18,
        ),
        label: const Text(
          'EDIT TEAM',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
      ),
    ),
    const SizedBox(width: 10),
    Expanded(
      child: OutlinedButton.icon(
        onPressed: previewTeam,
        icon: const Icon(
          Icons.visibility_outlined,
          size: 18,
        ),
        label: const Text(
          'PREVIEW TEAM',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        style: OutlinedButton.styleFrom(
  backgroundColor: const Color(0xFFE85D5D),
  foregroundColor: Colors.white,
  side: const BorderSide(
    color: Color(0xFFE85D5D),
    width: 1.5,
  ),
  padding: const EdgeInsets.symmetric(vertical: 14),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(22),
  ),
),
    ),
      ),
  ],   
),

const SizedBox(height: 10),
SizedBox(
  width: double.infinity,
  child: ElevatedButton(
    onPressed: openContests,
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFE85D5D),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 15),
      elevation: 1,
    ),
    child: const Text(
      'VIEW CONTESTS',
      style: TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
),
                  ],
                ),
              ),
            ),
          
            const SizedBox(height: 12),
            if (widget.match.status == 'LIVE' &&
    hasJoinedContest) ...[
              Card(
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          '🏆 Live Team Points',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          liveTeamPoints.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  ),
),
const SizedBox(height: 10),

Card(
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          '🏅 Your Live Rank',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '#$liveRank',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  ),
),
const SizedBox(height: 12),
  const Text(
    'Live Player Points',
    style: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  const SizedBox(height: 10),

  ...matchPlayers.map(
    (player) => Card(
      child: ListTile(
        title: Text(player.name),
        subtitle: Text(
          'Runs: ${player.runs}  •  Wickets: ${player.wickets}',
        ),
        trailing: Text(
          '${player.points.toStringAsFixed(0)} pts',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  ),

  const SizedBox(height: 12),
              
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: openContests,
                icon: const Icon(Icons.emoji_events),
                label: const Text('VIEW CONTESTS'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ================= TEAM PAGE =================
class TeamPage extends StatefulWidget {
  final List<Player> players;
  final List<Player> selected;

  final Function(Player captain, Player viceCaptain) onSave;
final Player? initialCaptain;
final Player? initialViceCaptain;
  const TeamPage({
    super.key,
    required this.players,
    required this.selected,
    required this.onSave,
    this.initialCaptain,
this.initialViceCaptain,
  });

  @override
  State<TeamPage> createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  String selectedRole = 'ALL';
Timer? teamLiveTimer;

@override
void initState() {
  super.initState();

  teamLiveTimer = Timer.periodic(
    const Duration(seconds: 1),
    (_) {
      if (!mounted) return;
      setState(() {});
    },
  );
}

@override
void dispose() {
  teamLiveTimer?.cancel();
  super.dispose();
}
  double get usedCredits {
    return widget.selected.fold<double>(
      0,
      (sum, player) => sum + player.credit,
    );
  }

  double get creditsLeft => 100 - usedCredits;

  int roleCount(String role) {
    return widget.selected.where((p) => p.role == role).length;
  }

  int teamCount(String team) {
    return widget.selected.where((p) => p.team == team).length;
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void togglePlayer(Player player) {
  final selectedIndex = widget.selected.indexWhere(
    (p) => p.name == player.name,
  );

  if (selectedIndex != -1) {
    setState(() {
      widget.selected.removeAt(selectedIndex);
    });

    return;
  }

    if (widget.selected.length >= 11) {
      showMessage('आप केवल 11 खिलाड़ी चुन सकते हैं');
      return;
    }

    if (player.credit > creditsLeft) {
      showMessage('आपके पास पर्याप्त credits नहीं हैं');
      return;
    }

    if (teamCount(player.team) >= 7) {
      showMessage('एक टीम से अधिकतम 7 खिलाड़ी चुन सकते हैं');
      return;
    }

    if (player.role == 'WK' && roleCount('WK') >= 4) {
      showMessage('अधिकतम 4 Wicket Keepers चुन सकते हैं');
      return;
    }

    if (player.role == 'BAT' && roleCount('BAT') >= 6) {
      showMessage('अधिकतम 6 Batsmen चुन सकते हैं');
      return;
    }

    if (player.role == 'AR' && roleCount('AR') >= 4) {
      showMessage('अधिकतम 4 All Rounders चुन सकते हैं');
      return;
    }

    if (player.role == 'BOWL' && roleCount('BOWL') >= 6) {
      showMessage('अधिकतम 6 Bowlers चुन सकते हैं');
      return;
    }

    setState(() {
      widget.selected.add(player);
    });
  }

  bool validateTeam() {
    if (widget.selected.length != 11) {
      showMessage('कृपया पूरे 11 खिलाड़ी चुनें');
      return false;
    }

    if (roleCount('WK') < 1) {
      showMessage('कम से कम 1 Wicket Keeper जरूरी है');
      return false;
    }

    if (roleCount('BAT') < 3) {
      showMessage('कम से कम 3 Batsmen जरूरी हैं');
      return false;
    }

    if (roleCount('AR') < 1) {
      showMessage('कम से कम 1 All Rounder जरूरी है');
      return false;
    }

    if (roleCount('BOWL') < 3) {
      showMessage('कम से कम 3 Bowlers जरूरी हैं');
      return false;
    }

    return true;
  }

  void continueTeam() {
    if (!validateTeam()) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            CaptainPage(
  selected: widget.selected,
  initialCaptain: widget.initialCaptain,
  initialViceCaptain: widget.initialViceCaptain,
  onSave: widget.onSave,
),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredPlayers = selectedRole == 'ALL'
        ? widget.players
        : widget.players.where((p) => p.role == selectedRole).toList();

    return Scaffold(
      appBar: AppBar(
  backgroundColor: const Color(0xFFE85D5D),
  foregroundColor: Colors.white,
  title: const Text('Create Team'),
),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        const Text('Players'),
                        Text(
                          '${widget.selected.length}/11',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Text('Credits Left'),
                        Text(
                          creditsLeft.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text('WK ${roleCount("WK")}'),
                    Text('BAT ${roleCount("BAT")}'),
                    Text('AR ${roleCount("AR")}'),
                    Text('BOWL ${roleCount("BOWL")}'),
                  ],
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                roleChip('ALL'),
                roleChip('WK'),
                roleChip('BAT'),
                roleChip('AR'),
                roleChip('BOWL'),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: filteredPlayers.length,
              itemBuilder: (context, index) {
                final player = filteredPlayers[index];

                final selected =
    widget.selected.any((p) => p.name == player.name);

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(child: Text(player.name[0])),
                    title: Text(
  player.name,
  style: const TextStyle(
    color: Color(0xFF8B3A3A),
    fontWeight: FontWeight.w600,
  ),
),
                    subtitle: Text(
  '${player.team} • ${player.role}\n'
  '${player.playing ? "🟢 Playing" : "🔴 Not Playing"}\n'
  'Points: ${player.points.toStringAsFixed(0)}',
),
                    isThreeLine: true,
                    trailing: SizedBox(
                      width: 90,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '${player.credit}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 10),
                          Icon(
                            selected ? Icons.remove_circle : Icons.add_circle,
                            color: selected ? Colors.red : Colors.green,
                          ),
                        ],
                      ),
                    ),
                    onTap: player.playing ? () => togglePlayer(player) : null,
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
  backgroundColor: const Color(0xFFE85D5D),
  foregroundColor: Colors.white,
),
                onPressed: widget.selected.length == 11 ? continueTeam : null,
                child: const Text('CONTINUE'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget roleChip(String role) {
  final bool isSelected = selectedRole == role;

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4),
    child: ChoiceChip(
      label: Text(
        role,
        style: TextStyle(
          color: isSelected
              ? Colors.white
              : const Color(0xFF6D4C41),
          fontWeight: FontWeight.bold,
        ),
      ),
      selected: isSelected,
      selectedColor: const Color(0xFFE85D5D),
      backgroundColor: const Color(0xFFFFF5F5),
      side: BorderSide(
        color: isSelected
            ? const Color(0xFFE85D5D)
            : const Color(0xFFD7C5C2),
      ),
      onSelected: (_) {
        setState(() {
          selectedRole = role;
        });
      },
    ),
  );
}
}

// ================= CAPTAIN PAGE =================
class CaptainPage extends StatefulWidget {
  final List<Player> selected;
final void Function(Player, Player) onSave;
final Player? initialCaptain;
final Player? initialViceCaptain;
  const CaptainPage({
  super.key,
  required this.selected,
  required this.onSave,
  this.initialCaptain,
  this.initialViceCaptain,
});

  @override
  State<CaptainPage> createState() => _CaptainPageState();
}

class _CaptainPageState extends State<CaptainPage> {
  Player? captain;
  Player? viceCaptain;
@override
void initState() {
  super.initState();

  captain = widget.initialCaptain;
  viceCaptain = widget.initialViceCaptain;
}
  void save() {
    if (captain == null || viceCaptain == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Captain और Vice Captain चुनें')),
      );

      return;
    }

    widget.onSave(captain!, viceCaptain!);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
  backgroundColor: const Color(0xFFE85D5D),
  foregroundColor: Colors.white,
  title: const Text('Choose Captain'),
),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(15),
            child: Text(
              'Captain को 2X और Vice Captain को 1.5X points मिलेंगे',
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.selected.length,
              itemBuilder: (context, index) {
                final player = widget.selected[index];

                return Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text(player.name[0])),
                    title: Text(
  player.name,
  style: const TextStyle(
    color: Color(0xFF8B3A3A),
    fontWeight: FontWeight.w600,
  ),
),
                    subtitle: Text('${player.team} • ${player.role}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ChoiceChip(
  label: Text(
    'C',
    style: TextStyle(
      color: captain == player
          ? Colors.white
          : const Color(0xFF6D4C41),
      fontWeight: FontWeight.bold,
    ),
  ),
  selected: captain == player,
  selectedColor: const Color(0xFFE85D5D),
  backgroundColor: const Color(0xFFFFF5F5),
                          onSelected: (_) {
                            setState(() {
                              captain = player;

                              if (viceCaptain == player) {
                                viceCaptain = null;
                              }
                            });
                          },
                        ),
                        const SizedBox(width: 5),
                        ChoiceChip(
  label: Text(
    'VC',
    style: TextStyle(
      color: viceCaptain == player
          ? Colors.white
          : const Color(0xFF6D4C41),
      fontWeight: FontWeight.bold,
    ),
  ),
  selected: viceCaptain == player,
  selectedColor: const Color(0xFFE85D5D),
  backgroundColor: const Color(0xFFFFF5F5),
                          onSelected: (_) {
                            if (captain == player) {
                              return;
                            }

                            setState(() {
                              viceCaptain = player;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: save,
                style: ElevatedButton.styleFrom(
  backgroundColor: const Color(0xFFE85D5D),
  foregroundColor: Colors.white,
  padding: const EdgeInsets.symmetric(vertical: 15),
  textStyle: const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  ),
),
                child: const Text('SAVE TEAM'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================= TEAM PREVIEW =================

class TeamPreviewPage extends StatelessWidget {
  final List<Player> selected;
  final Player? captain;
  final Player? viceCaptain;
final String matchKey;
  const TeamPreviewPage({
    super.key,
    required this.selected,
    required this.captain,
    required this.viceCaptain,
    required this.matchKey,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Team Preview')),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            const Text(
              '🏏 MY TEAM',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: GridView.builder(
                itemCount: selected.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.72,
                ),
                itemBuilder: (context, index) {
                  final player = selected[index];
final matchStats = savedPlayerStats[matchKey] ?? {};

Map<String, int>? stats;

for (final entry in matchStats.entries) {
  if (entry.key.split('|').first.trim() == player.name.trim()) {
    stats = entry.value;
    break;
  }
}

final runs = stats?['runs'] ?? 0;
final fours = stats?['fours'] ?? 0;
final sixes = stats?['sixes'] ?? 0;
final wickets = stats?['wickets'] ?? 0;
final catches = stats?['catches'] ?? 0;

final basePoints =
    runs +
    (fours * 2) +
    (sixes * 4) +
    (wickets * 30) +
    (catches * 10);

double points = basePoints.toDouble();

if (player == captain) {
  points *= 2;
} else if (player == viceCaptain) {
  points *= 1.5;
}
                  String badge = '';

if (player == captain) {
  badge = 'C';
} else if (player == viceCaptain) {
  badge = 'VC';
}

                  return Card(
                    color: player.role == 'WK'
    ? const Color(0xFFBBDEFB)
    : player.role == 'BAT'
        ? const Color(0xFFFFCDD2)
        : player.role == 'AR'
            ? const Color(0xFFC8E6C9)
            : const Color(0xFFFFECB3),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(child: Text(player.name[0])),
                          const SizedBox(height: 6),
                          Text(
  player.name,
  textAlign: TextAlign.center,
  style: const TextStyle(
    color: Color(0xFF8B3A3A),
    fontWeight: FontWeight.bold,
  ),
),

if (badge.isNotEmpty) ...[
  const SizedBox(height: 5),
  Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 10,
      vertical: 4,
    ),
    decoration: BoxDecoration(
      color: badge == 'C'
          ? const Color(0xFFD32F2F)
          : const Color(0xFF3949AB),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      badge,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 13,
      ),
    ),
  ),
],
                          Text(player.role),
                          Text(player.team),
                         
                        ],
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
}

// ================= CONTEST PAGE =================

class ContestPage extends StatelessWidget {
  final bool teamSaved;
  final Player? captain;
  final Player? viceCaptain;
  final List<Player> selected;
  final MatchModel match;
  final String matchKey;

  ContestPage({
    super.key,
    required this.teamSaved,
    required this.captain,
    required this.viceCaptain,
    required this.selected,
    required this.match,
    required this.matchKey,
  });
  
double get totalPoints {
  return selected.fold<double>(0, (sum, player) {
    double multiplier = 1;

    if (player.name == captain?.name) {
  multiplier = 2;
} else if (player.name == viceCaptain?.name) {
  multiplier = 1.5;
}

    return sum + player.points * multiplier;
  });
}


  List<Map<String, dynamic>> get leaderboardEntries {
  final entries = <Map<String, dynamic>>[
    {
      'name': 'You',
      'points': totalPoints,
      'isUser': true,
    },
    {
      'name': 'Cricket King',
      'points': 742.0,
      'isUser': false,
    },
    {
      'name': 'Super XI',
      'points': 711.0,
      'isUser': false,
    },
  ];

  entries.sort(
    (a, b) => (b['points'] as double)
        .compareTo(a['points'] as double),
  );

  return entries;
}

int get contestRank {
  return leaderboardEntries.indexWhere(
        (item) => item['isUser'] == true,
      ) +
      1;
}

  void joinContest(
  BuildContext context,
  double entryFee,
  String contestName,
  int contestSpots,
  double prizePool, {
  String contestId = '',
    String winningType = '',
  List<dynamic>? prizeSlabs,
}) {
    if (match.status != 'UPCOMING') {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Match शुरू हो चुका है, अब contest join नहीं कर सकते'),
    ),
  );
  return;
}
    // Same contest ko ek user dobara join na kar sake
final bool alreadyJoinedThisContest =
    joinedContests.value.any((c) {
  final bool sameMatch =
      (c['matchKey'] ?? '').toString() == matchKey;

  if (!sameMatch) return false;

  final String oldContestId =
      (c['contestId'] ?? '').toString();

  // Contest ID available hai to wahi strongest check hai
  if (contestId.isNotEmpty && oldContestId.isNotEmpty) {
    return oldContestId == contestId;
  }

  // Fallback for old/empty contest ID
  final String oldWinningType =
      (c['h2hWinningType'] ??
              c['winningType'] ??
              '')
          .toString()
          .trim();

  return (c['contestName'] ?? '').toString() ==
          contestName &&
      oldWinningType == winningType.trim();
});

if (alreadyJoinedThisContest) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        'You have already joined this contest',
      ),
    ),
  );
  return;
}
    final current =
    List<MatchModel>.from(joinedMatches.value);

final alreadyJoined = current.any(
  (m) => m.team1 == match.team1 && m.team2 == match.team2,
);


    // हर contest join पर entry fee कटेगी
if (walletBalance.value < entryFee) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        'Insufficient Wallet Balance • Available ₹${walletBalance.value.toStringAsFixed(0)}',
      ),
    ),
  );
  return;
}


walletBalance.value -= entryFee;

final history =
    List<Map<String, dynamic>>.from(transactionHistory.value);

final now = DateTime.now();
String shortTeamName(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));

  if (parts.length == 1) {
    final word = parts.first.toUpperCase();
    return word.length <= 3
        ? word
        : word.substring(0, 3);
  }

  return parts
      .take(3)
      .map((e) => e[0].toUpperCase())
      .join();
}
    final txnNumber =
    generateTxnNumber('ENTRY');
history.add({
  'title': 'Contest Entry',
  'txnNumber': txnNumber,
  'subtitle': contestName,
'winningType': winningType,
  'description':
    '${match.team1Flag} ${shortTeamName(match.team1)} '
    'vs ${shortTeamName(match.team2)} ${match.team2Flag} '
    '• ${match.matchFormat}',
   'dateTime':
  '${now.day.toString().padLeft(2, '0')}/'
      '${now.month.toString().padLeft(2, '0')}/'
      '${now.year}  '
      '${now.hour.toString().padLeft(2, '0')}:'
      '${now.minute.toString().padLeft(2, '0')}',
  'team1': match.team1,
  'team2': match.team2,
  'amount': -entryFee,
});

transactionHistory.value = history;

// My Matches में same match केवल एक बार add होगा
if (!alreadyJoined) {
  current.add(
    MatchModel(
      team1: match.team1,
      team2: match.team2,
      team1Flag: match.team1Flag,
      team2Flag: match.team2Flag,
      title: match.title,
      time: match.time,
      status: match.status,
      startTime: match.startTime,
      liveDuration: match.liveDuration,
      userRank: contestRank,
      userPoints: totalPoints.round(),
      contestName: contestName,
      contestSpots: contestSpots,
      entryFee: entryFee,
      
    ),
  );

  joinedMatches.value = current;
}

// लेकिन My Contests में हर join अलग save होगा
final contestList =
    List<Map<String, dynamic>>.from(joinedContests.value);
int joinedTeamNumber = 1;
int sameMatchTeamCount = 0;
int existingTeamIndex = -1;

for (int i = 0; i < savedTeams.value.length; i++) {
  if (i < savedTeamMatchKeys.length &&
      savedTeamMatchKeys[i] == matchKey) {
    sameMatchTeamCount++;

    final savedTeam = savedTeams.value[i];

    final isSameTeam =
        savedTeam.length == selected.length &&
        savedTeam.every(
          (p) => selected.any((s) => s.name == p.name),
        );

    if (isSameTeam) {
      joinedTeamNumber = sameMatchTeamCount;
      existingTeamIndex = i;
      break;
    }
  }
}

if (existingTeamIndex == -1) {
  joinedTeamNumber = sameMatchTeamCount + 1;

  final newTeams =
      List<List<Player>>.from(savedTeams.value);

  newTeams.add(
    selected.map((p) {
      return Player(
        name: p.name,
        role: p.role,
        team: p.team,
        credit: p.credit,
        playing: p.playing,
        runs: 0,
        fours: 0,
        sixes: 0,
        wickets: 0,
        catches: 0,
      );
    }).toList(),
  );

  savedCaptainNames.add(captain?.name ?? '');
  savedViceCaptainNames.add(viceCaptain?.name ?? '');
  savedTeamMatchKeys.add(matchKey);
  savedTeams.value = newTeams;
  final drafts =
    Map<String, Map<String, dynamic>>.from(draftTeams.value);

drafts.remove(matchKey);
draftTeams.value = drafts;
}
contestList.add({
  'joinedAt': DateTime.now(),
   'joinId':
    '${match.team1}_${match.team2}_${contestName}_${DateTime.now().microsecondsSinceEpoch}',
'contestId': contestId,

  // जिस team से यह contest join किया है वही team इसमें lock रहेगी
  'selectedPlayers': List<Player>.from(selected),
'joinedTeamName': 'Team $joinedTeamNumber',
  'captainName': captain?.name ?? '',
  'viceCaptainName': viceCaptain?.name ?? '',

  'match': '${match.team1} vs ${match.team2}',
  'team1': match.team1,
  'team2': match.team2,
'matchKey': matchKey,
  'contestName': contestName,
'winningType': contestName == 'Head to Head'
    ? winningType
    : '',
'h2hWinningType': contestName == 'Head to Head'
    ? winningType
    : '',
  'entryFee': entryFee,
  'spots': contestSpots,
'prizePool': prizePool,
  'prizeSlabs': List<dynamic>.from(
  prizeSlabs ?? const [],
),
  
  'userId': 'user1',
  'userPoints': totalPoints,
});

joinedContests.value = contestList;
    

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('🎉 Joined Successfully'),
        content: const Text(
  'आपकी team contest में join हो गई है.',
),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contests')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          
const SizedBox(height: 12),
     
if (match.currentStatus != 'UPCOMING')
  Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🏆 Leaderboard',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          ...leaderboardEntries.asMap().entries.map((entry) {
            final rank = entry.key + 1;
            final item = entry.value;
            final points = item['points'] as double;
            final isUser = item['isUser'] == true;

            return ListTile(
              leading: CircleAvatar(
                child: Text('$rank'),
              ),
              title: Text(
                '${item['name']}',
                style: TextStyle(
                  fontWeight:
                      isUser ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              trailing: Text(
                '${points.toStringAsFixed(0)} pts',
              ),
            );
          }),
        ],
      ),
    ),
  ),
ValueListenableBuilder<double>(
  valueListenable: walletBalance,
  builder: (context, balance, _) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(
          top: 8,
          right: 4,
          bottom: 14,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 9,
        ),
        decoration: BoxDecoration(
          color: Colors.green.shade700,
        borderRadius:
BorderRadius.circular(16),
          border: Border.all(
  color: Colors.green.shade800,

          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.account_balance_wallet,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 6),
            Text(
              '₹${balance.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  },
),
const SizedBox(height: 16),
           Text.rich(
  TextSpan(
    children: [
      TextSpan(
        text:
    '${match.team1} vs ${match.team2} • ${match.matchFormat}',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF7A3E48),
        ),
      ),
      const TextSpan(
        text: ' • Available Contests',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2E7D6B),
        ),
      ),
    ],
  ),
),
...createdContests.where((contest) {
  final contestMatch = contest['match'];

  final cTeam1 = (
    contest['team1'] ??
    (contestMatch is Map ? contestMatch['team1'] : null)
  )?.toString().trim().toLowerCase();

  final cTeam2 = (
    contest['team2'] ??
    (contestMatch is Map ? contestMatch['team2'] : null)
  )?.toString().trim().toLowerCase();

  return cTeam1 == match.team1.trim().toLowerCase() &&
      cTeam2 == match.team2.trim().toLowerCase();
}).map((contest) {
  final totalSpots =
      int.tryParse(contest['spots'].toString()) ?? 0;

  final fee =
    double.tryParse(contest['fee'].toString()) ?? 0.0;

final prizePool =
    double.tryParse(contest['prize'].toString()) ?? 0.0;

  final joinedNotifier =
    contest['joinedNotifier'] as ValueNotifier<int>? ??
        ValueNotifier<int>(0);

contest['joinedNotifier'] = joinedNotifier;
final currentContestId =
    (contest['id'] ?? '').toString();

final currentWinningType =
    (contest['h2hWinningType'] ??
            contest['winningType'] ??
            '')
        .toString();


return ValueListenableBuilder<int>(
  valueListenable: joinedNotifier,
  builder: (context, joined, _) {
    

    final alreadyJoinedThisContest =
        joinedContests.value.any((joinedContest) {
      final sameMatch =
          joinedContest['matchKey'] == matchKey;

      final joinedContestId =
          (joinedContest['contestId'] ?? '')
              .toString();

      if (currentContestId.isNotEmpty &&
          joinedContestId.isNotEmpty) {
        return sameMatch &&
            joinedContestId == currentContestId;
      }

      return sameMatch &&
          joinedContest['contestName'] ==
              contest['name'] &&
          (joinedContest['h2hWinningType'] ??
                  joinedContest['winningType'] ??
                  '')
              .toString() ==
              currentWinningType;
    });

    return ContestCard(
      showJoinButton: teamSaved,
      name: contest['name'] == 'Head to Head' &&
        ((contest['h2hWinningType'] ??
                contest['winningType'] ??
                '')
            .toString()
            .trim()
            .isNotEmpty)
    ? '${contest['name']} • ${contest['h2hWinningType'] ?? contest['winningType']}'
    : contest['name'].toString(),
      prize: '₹${contest['prize']}',
      entry: '₹${contest['fee']}',
      spots: '${contest['spots']} Spots',
      joinedCount: joined,
      totalSpots: totalSpots,
      prizeSlabs: contest['prizeSlabs'] is List
    ? List<dynamic>.from(contest['prizeSlabs'])
    : const [],
      onJoin: teamSaved &&
    match.status == 'UPCOMING' &&
    joined < totalSpots &&
    !alreadyJoinedThisContest
          ? () {
              final beforeJoinCount = joinedContests.value.length;
            joinContest(
  context,
  fee,
  contest['name'].toString(),
  totalSpots,
  prizePool,
  contestId: (contest['id'] ?? '').toString(),
  winningType:
    (contest['h2hWinningType'] ??
     contest['winningType'] ??
     '').toString(),
                prizeSlabs: contest['prizeSlabs'] is List
      ? List<dynamic>.from(contest['prizeSlabs'])
      : const [],
);

              if (joinedContests.value.length > beforeJoinCount) {
  joinedNotifier.value++;
}
            }
          : null,
    );
  },
);
}).toList(),

          
          const SizedBox(height: 10),
          const Text(
            'Demo only • No real money transaction',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// ================= CONTEST CARD =================

class ContestCard extends StatelessWidget {
  final String name;
  final String prize;
  final String entry;
  final String spots;
  final VoidCallback? onJoin;
  final bool showJoinButton;
final int joinedCount;
final int totalSpots;
  final List<dynamic> prizeSlabs;
  const ContestCard({
    super.key,
    required this.name,
    required this.prize,
    required this.entry,
    required this.spots,
    required this.onJoin,
    required this.showJoinButton,
    required this.prizeSlabs,
    this.joinedCount = 0,
this.totalSpots = 0,
  });

  @override
  Widget build(BuildContext context) {
    final bool isFull = totalSpots > 0 && joinedCount >= totalSpots;
    final int spotsLeft = totalSpots - joinedCount;
    final bool isJoined = joinedCount > 0;

    final lowerName = name.toLowerCase();

final Color contestCardColor =
    lowerName.contains('mega')
        ? const Color(0xFFF1E8FF)
        : lowerName.contains('small')
            ? const Color(0xFFFFF1DB)
            : lowerName.contains('rank wise')
                ? const Color(0xFFE8F7EC)
                : lowerName.contains('winner takes all')
                    ? const Color(0xFFFFE8EA)
                    : const Color(0xFFFFF7F4);
    final Color contestBorderColor =
    lowerName.contains('mega')
        ? const Color(0xFFB99AE8)
        : lowerName.contains('small')
            ? const Color(0xFFE5B96F)
            : lowerName.contains('rank wise')
                ? const Color(0xFF86C995)
                : lowerName.contains('winner takes all')
                    ? const Color(0xFFE89AA5)
                    : const Color(0xFFE7C9BC);
    return Card(
  margin: const EdgeInsets.only(bottom: 8),
  color: contestCardColor,
  elevation: 1.5,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(18),
    side: BorderSide(
  color: contestBorderColor,
  width: 1.4,
),
  ),
  child: Padding(
    padding: const EdgeInsets.fromLTRB(12, 8, 12, 7),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
  padding: const EdgeInsets.symmetric(
  horizontal: 12,
  vertical: 7,
),
  decoration: BoxDecoration(
    color: const Color(0xFFFFEFEB),
    borderRadius: BorderRadius.circular(14),
    border: Border.all(
      color: const Color(0xFFEAD4CC),
    ),
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Icon(
        Icons.emoji_events_outlined,
        size: 22,
        color: Color(0xFFA45A50),
      ),
      const SizedBox(width: 8),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Prize Pool',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
          Text(
            prize,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ],
  ),
),
                Container(
  padding: const EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 7,
  ),
  decoration: BoxDecoration(
    color: const Color(0xFFFFEFEB),
    borderRadius: BorderRadius.circular(14),
    border: Border.all(
      color: const Color(0xFFEAD4CC),
    ),
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Icon(
        Icons.confirmation_number_outlined,
        size: 22,
        color: Color(0xFFA45A50),
      ),
      const SizedBox(width: 8),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Entry',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
          Text(
            entry,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ],
  ),
),
                  
                ElevatedButton(
  onPressed: (isFull || isJoined) ? null : onJoin,
  style: ElevatedButton.styleFrom(
    elevation: 0,
    backgroundColor: const Color(0xFF43A047),
foregroundColor: Colors.white,

    disabledBackgroundColor: isJoined
    ? const Color(0xFF000000)
    : const Color(0xFFE0E0E0),
disabledForegroundColor: isJoined
    ? const Color(0xFFFFFFFF)
    : const Color(0xFF757575),
    

    padding: const EdgeInsets.symmetric(
      horizontal: 20,
      vertical: 9,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(22),
    ),
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        isJoined
            ? 'JOINED'
            : isFull
                ? 'FULL'
                : 'JOIN',
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      if (isJoined) ...[
        const SizedBox(width: 5),
        const Icon(
          Icons.check,
          size: 18,
        ),
      ],
    ],
  ),
),
            ],
),
            const SizedBox(height: 6),

if (prizeSlabs.isNotEmpty)
  Align(
    alignment: Alignment.centerRight,
    child: TextButton.icon(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          builder: (sheetContext) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                 children: [
                   
                   Text(
  name,
  style: const TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: Color(0xFF3A2A2A),
  ),
),

const SizedBox(height: 10),

Container(
  width: double.infinity,
  padding: const EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 14,
  ),
  decoration: BoxDecoration(
    color: const Color(0xFFFFF4D9),
    borderRadius: BorderRadius.circular(18),
    border: Border.all(
      color: const Color(0xFFF2D17C),
      width: 1,
    ),
  ),
  child: const Row(
    children: [
      Icon(
        Icons.emoji_events,
        color: Color(0xFFC58B00),
        size: 28,
      ),
      SizedBox(width: 10),
      Text(
        'Prize Breakdown',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  ),
),

const SizedBox(height: 16),

                    ...prizeSlabs.map((rawSlab) {
                      if (rawSlab is! Map) {
                        return const SizedBox.shrink();
                      }

                      final slab =
                          Map<String, dynamic>.from(
                        rawSlab,
                      );
                final fromRank =
                          slab['fromRank'] ??
                          slab['rankFrom'] ??
                          slab['startRank'] ??
                          slab['from'] ??
                          slab['start'] ??
                          slab['rank'];

                      final toRank =
                          slab['toRank'] ??
                          slab['rankTo'] ??
                          slab['endRank'] ??
                          slab['to'] ??
                          slab['end'] ??
                          fromRank;

                      final prizeAmount =
                          slab['prize'] ??
                          slab['amount'] ??
                          slab['winning'] ??
                          slab['winnings'] ??
                          0;

                      final rankText =
                          fromRank.toString() ==
                                  toRank.toString()
                              ? 'Rank $fromRank'
                              : 'Rank $fromRank - $toRank';

                      return Container(
  width: double.infinity,
  margin: const EdgeInsets.only(bottom: 10),
  padding: const EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 14,
  ),
  decoration: BoxDecoration(
    color: const Color(0xFFFFF9EC),
    borderRadius: BorderRadius.circular(18),
    border: Border.all(
      color: const Color(0xFFECCF8B),
      width: 1,
    ),
  ),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        rankText,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      Text(
        '₹$prizeAmount',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  ),
);
                    }),

                    const SizedBox(height: 16),

SizedBox(
  width: double.infinity,
  height: 52,
  child: ElevatedButton(
    onPressed: () {
      Navigator.pop(sheetContext);
    },
    style: ElevatedButton.styleFrom(
      elevation: 0,
      backgroundColor: const Color(0xFFFF5A58),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(26),
      ),
    ),
    child: const Text(
      'Close',
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
),
                  ],
                ),
              ),
            );
          },
        );
      },
      style: TextButton.styleFrom(
  backgroundColor: const Color(0xFFFFF4D9),
  foregroundColor: const Color(0xFF7A5200),
  padding: const EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 10,
  ),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(18),
    side: const BorderSide(
      color: Color(0xFFF2D17C),
      width: 1,
    ),
  ),
),
      icon: const Icon(
        Icons.emoji_events_outlined,
        size: 18,
      ),
      label: const Text('Prize Breakdown'),
    ),
  ),

const SizedBox(height: 10),      
                      
            Text(
  totalSpots > 0
      ? '$joinedCount/$totalSpots Joined'
      : spots,
),
            const SizedBox(height: 6),

if (totalSpots > 0) ...[
  Text('$spotsLeft Spots Left'),

  const SizedBox(height: 6),

  Align(
  alignment: Alignment.centerLeft,
  child: SizedBox(
    width: 140,
    child: LinearProgressIndicator(
  value: totalSpots > 0
      ? joinedCount / totalSpots
      : 0.0,
  minHeight: 6,
  borderRadius: BorderRadius.circular(10),
  color: Colors.red,
  backgroundColor: Colors.green,
),
    
      ),
    ),
  
  
],
          ],
        ),
      ),
    );
  }
}

        class MyContestsPage extends StatefulWidget {
  const MyContestsPage({super.key});

  @override
  State<MyContestsPage> createState() => _MyContestsPageState();
}

class _MyContestsPageState extends State<MyContestsPage> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
  length: 2,
  child: Scaffold(
    appBar: AppBar(
      title: const Text('My Contests'),
     bottom: PreferredSize(
  preferredSize: const Size.fromHeight(74),
  child: Padding(
    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
    child: Stack(
      alignment: Alignment.center,
      children: [
        TabBar(
          onTap: (index) {
            setState(() {
              selectedTab = index;
            });
          },
          indicatorColor: Colors.transparent,
          dividerColor: Colors.transparent,
          labelPadding: EdgeInsets.zero,
          tabs: [
            Tab(
              height: 48,
              child: Container(
                margin: const EdgeInsets.only(right: 18),
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: selectedTab == 0
                      ? const Color(0xFF238A4B)
                      : const Color(0xFFDDEBE2),
                  border: Border.all(
                    color: const Color(0xFF4CAF76),
                    width: 1.6,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Icon(
                      Icons.bolt_rounded,
                      size: 18,
                      color: selectedTab == 0
                          ? Colors.white
                          : const Color(0xFF238A4B),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Current',
                      style: TextStyle(
                        color: selectedTab == 0
                            ? Colors.white
                            : const Color(0xFF238A4B),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
      Tab(
              height: 48,
              child: Container(
                margin: const EdgeInsets.only(left: 18),
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: selectedTab == 1
                      ? const Color(0xFF7048A8)
                      : const Color(0xFFECE3F7),
                  border: Border.all(
                    color: const Color(0xFF8B63C7),
                    width: 1.6,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 17,
                      color: selectedTab == 1
                          ? Colors.white
                          : const Color(0xFF7048A8),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Archived',
                      style: TextStyle(
                        color: selectedTab == 1
                            ? Colors.white
                            : const Color(0xFF7048A8),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        IgnorePointer(
          child: Container(
            height: 42,
            width: 1.4,
            color: const Color(0xFFD2CCCC),
          ),
        ),
      ],
    ),
  ),
),
      ),
      body: ValueListenableBuilder<List<Map<String, dynamic>>>(
        valueListenable: joinedContests,
        builder: (context, contests, _) {
          MatchModel? findLinkedMatch(Map<String, dynamic> contest) {
  final matchName =
      (contest['match'] ?? '')
          .toString()
          .trim()
          .toLowerCase();

  for (final m in joinedMatches.value) {
    final joinedMatchName =
        '${m.team1} vs ${m.team2}'
            .trim()
            .toLowerCase();

    if (joinedMatchName == matchName) {
      return m;
    }
  }

  return null;
}

// CURRENT CONTESTS
final visibleContests = contests.where((contest) {
  final linkedMatch = findLinkedMatch(contest);

  if (linkedMatch == null ||
      linkedMatch.currentStatus != 'COMPLETED') {
    return true;
  }

  final completionTime =
      linkedMatch.completedAt ??
      linkedMatch.startTime?.add(linkedMatch.liveDuration);

  if (completionTime == null) {
    return true;
  }

  final archiveAt =
    completionTime.add(const Duration(days: 1));

  return DateTime.now().isBefore(archiveAt);
}).toList();

// ARCHIVED CONTESTS
final archivedContests = contests.where((contest) {
  final linkedMatch = findLinkedMatch(contest);

  if (linkedMatch == null ||
      linkedMatch.currentStatus != 'COMPLETED') {
    return false;
  }

  final completionTime =
      linkedMatch.completedAt ??
      linkedMatch.startTime?.add(linkedMatch.liveDuration);

  if (completionTime == null) {
    return false;
  }

  final archiveAt =
    completionTime.add(const Duration(days: 1));

final deleteAt =
    archiveAt.add(const Duration(days: 5));

  final now = DateTime.now();

  return !now.isBefore(archiveAt) &&
      now.isBefore(deleteAt);
}).toList();
          Widget contestList(
    List<Map<String, dynamic>> sourceContests,
    String emptyText,
) {
           if (sourceContests.isEmpty) {
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
  width: 270,
  height: 270,
  child: Stack(
    clipBehavior: Clip.none,
    alignment: Alignment.center,
    children: [

      // LIGHT BACKGROUND CIRCLE
      Container(
        width: 220,
        height: 220,
        decoration: const BoxDecoration(
          color: Color(0xFFFFF3E0),
          shape: BoxShape.circle,
        ),
      ),

      // COLORFUL SPARKLES
      const Positioned(
        left: 8,
        top: 105,
        child: Text('✦', style: TextStyle(
          fontSize: 34,
          color: Color(0xFF7C4DFF),
        )),
      ),
      const Positioned(
        right: 5,
        top: 100,
        child: Text('✦', style: TextStyle(
          fontSize: 32,
          color: Color(0xFFFFC107),
        )),
      ),
      const Positioned(
        left: 22,
        bottom: 48,
        child: Text('✦', style: TextStyle(
          fontSize: 28,
          color: Color(0xFF00C853),
        )),
      ),
      const Positioned(
        right: 16,
        bottom: 52,
        child: Text('✦', style: TextStyle(
          fontSize: 27,
          color: Color(0xFFFF4081),
        )),
      ),
// EXTRA UPRIGHT NOTES + MONEY BAG + MONEY FACE

// LEFT UPRIGHT NOTE
Positioned(
  left: 62,
  top: -28,
  child: Transform.rotate(
    angle: -0.16,
    child: const Text(
      '💵',
      style: TextStyle(fontSize: 82),
    ),
  ),
),

// RIGHT UPRIGHT NOTE
Positioned(
  right: 54,
  top: -28,
  child: Transform.rotate(
    angle: 0.16,
    child: const Text(
      '💷',
      style: TextStyle(fontSize: 82),
    ),
  ),
),

// MONEY BAG - CENTER
Positioned(
  left: 0,
  right: 0,
  top: -10,
  child: Center(
    child: Text(
      '💰',
      style: TextStyle(
        fontSize: 76,
        height: 1.0,
      ),
    ),
  ),
),

// MONEY FACE - BAG KE UPAR
Positioned(
  left: 0,
  right: 0,
  top: -64,
  child: Center(
    child: Text(
      '🤑',
      style: TextStyle(
        fontSize: 62,
        height: 1.0,
      ),
    ),
  ),
),

// TOP LEFT $ COIN
Positioned(
  left: 48,
  top: 5,
  child: Container(
    width: 44,
    height: 44,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: const Color(0xFF81C784),
      shape: BoxShape.circle,
      border: Border.all(
        color: const Color(0xFFFF9800),
        width: 3,
      ),
    ),
    child: const Text(
      r'$',
      style: TextStyle(
        fontSize: 25,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1B5E20),
      ),
    ),
  ),
),

// TOP RIGHT ₹ COIN
Positioned(
  right: 42,
  top: 3,
  child: Container(
    width: 44,
    height: 44,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: const Color(0xFF64B5F6),
      shape: BoxShape.circle,
      border: Border.all(
        color: const Color(0xFFFF9800),
        width: 3,
      ),
    ),
    child: const Text(
      '₹',
      style: TextStyle(
        fontSize: 23,
        fontWeight: FontWeight.bold,
        color: Color(0xFF0D47A1),
      ),
    ),
  ),
),
      // MONEY EMOJI NOTES - TROPHY KE PICHE

 Positioned(
  left: 28,
  top: 23,
  child: Transform.rotate(
    angle: -0.35,
    child: Text(
      '💵',
      style: TextStyle(fontSize: 76),
    ),
  ),
),

 Positioned(
  left: 75,
  top: 0,
  child: Transform.rotate(
    angle: -0.15,
    child: Text(
      '💷',
      style: TextStyle(fontSize: 82),
    ),
  ),
),

 Positioned(
  right: 68,
  top: 0,
  child: Transform.rotate(
    angle: 0.15,
    child: Text(
      '💶',
      style: TextStyle(fontSize: 80),
    ),
  ),
),

 Positioned(
  right: 22,
  top: 25,
  child: Transform.rotate(
    angle: 0.35,
    child: Text(
      '💴',
      style: TextStyle(fontSize: 74),
    ),
  ),
),

 Positioned(
  left: 115,
  top: 39,
  child: Transform.rotate(
    angle: -0.08,
    child: Text(
      '💸',
      style: TextStyle(fontSize: 65),
    ),
  ),
),

const Positioned(
  right: 103,
  top: 44,
  child: Text(
    '💰',
    style: TextStyle(fontSize: 57),
  ),
),
      
// ===== EXTRA WINNING COINS + SPARKLES =====

// EXTRA ₹ COIN - TOP LEFT
Positioned(
  left: 18,
  top: 8,
  child: Container(
    width: 34,
    height: 34,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: const Color(0xFFFFC107),
      shape: BoxShape.circle,
      border: Border.all(
        color: const Color(0xFFFF9800),
        width: 3,
      ),
    ),
    child: const Text(
      '₹',
      style: TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.bold,
        color: Color(0xFF8D4B00),
      ),
    ),
  ),
),

// EXTRA $ COIN - TOP RIGHT
Positioned(
  right: 12,
  top: 2,
  child: Container(
    width: 36,
    height: 36,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: const Color(0xFFFFC107),
      shape: BoxShape.circle,
      border: Border.all(
        color: const Color(0xFFFF9800),
        width: 3,
      ),
    ),
    child: const Text(
      '\$',
      style: TextStyle(
        fontSize: 21,
        fontWeight: FontWeight.bold,
        color: Color(0xFF8D4B00),
      ),
    ),
  ),
),

// EXTRA ₹ COIN - LEFT MIDDLE
Positioned(
  left: 4,
  top: 90,
  child: Container(
    width: 30,
    height: 30,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: const Color(0xFFCE93D8),
      shape: BoxShape.circle,
      border: Border.all(
        color: const Color(0xFFFF9800),
        width: 2.5,
      ),
    ),
    child: const Text(
      '₹',
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: Color(0xFF6A1B9A),
      ),
    ),
  ),
),
    // EXTRA $ COIN - RIGHT MIDDLE
Positioned(
  right: 3,
  top: 88,
  child: Container(
    width: 31,
    height: 31,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: const Color(0xFFFF8A80),
      shape: BoxShape.circle,
      border: Border.all(
        color: const Color(0xFFFF9800),
        width: 2.5,
      ),
    ),
    child: const Text(
      '\$',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFFB71C1C),
      ),
    ),
  ),
),

// PURPLE SPARKLE
const Positioned(
  left: 5,
  top: 58,
  child: Text(
    '✦',
    style: TextStyle(
      fontSize: 30,
      color: Color(0xFF7C4DFF),
      fontWeight: FontWeight.bold,
    ),
  ),
),

// PINK SPARKLE
const Positioned(
  right: 2,
  top: 48,
  child: Text(
    '✦',
    style: TextStyle(
      fontSize: 24,
      color: Color(0xFFFF4081),
      fontWeight: FontWeight.bold,
    ),
  ),
),

// GREEN SPARKLE
const Positioned(
  left: 15,
  bottom: 48,
  child: Text(
    '✦',
    style: TextStyle(
      fontSize: 27,
      color: Color(0xFF00C853),
      fontWeight: FontWeight.bold,
    ),
  ),
),

// YELLOW SPARKLE
const Positioned(
  right: 7,
  bottom: 72,
  child: Text(
    '✦',
    style: TextStyle(
      fontSize: 30,
      color: Color(0xFFFFC400),
      fontWeight: FontWeight.bold,
    ),
  ),
),

// SMALL BLUE SPARKLE
const Positioned(
  left: 48,
  top: 2,
  child: Text(
    '◆',
    style: TextStyle(
      fontSize: 13,
      color: Color(0xFF40C4FF),
    ),
  ),
),

// SMALL PINK SPARKLE
const Positioned(
  right: 45,
  top: 13,
  child: Text(
    '◆',
    style: TextStyle(
      fontSize: 14,
      color: Color(0xFFFF80AB),
    ),
  ),
),  
      
      // BIG TROPHY 🏆
const Positioned(
  bottom: 0,
  left: 0,
  right: 0,
  child: Center(
    child: Text(
      '🏆',
      style: TextStyle(
        fontSize: 180,
        height: 1.0,
      ),
    ),
  ),
),

      // ₹ COIN
      Positioned(
        left: 28,
        top: 36,
        child: Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFFFC107),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFFF9800),
              width: 3,
            ),
          ),
          child: const Text(
            '₹',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8D4B00),
            ),
          ),
        ),
      ),

      // $ COIN
      Positioned(
        right: 30,
        top: 28,
        child: Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFFFC107),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFFF9800),
              width: 3,
            ),
          ),
          child: const Text(
            '\$',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8D4B00),
            ),
          ),
        ),
      ),
        // SECOND ₹ COIN
      Positioned(
        left: 45,
        bottom: 30,
        child: Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFFFC107),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFFF9800),
              width: 3,
            ),
          ),
          child: const Text(
            '₹',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8D4B00),
            ),
          ),
        ),
      ),

      // BIG 🚫 BADGE - TROPHY SE CHIPKA HUA
      Positioned(
        right: 12,
        bottom: 12,
        child: Container(
          width: 100,
          height: 100,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.block_rounded,
            size: 82,
            color: Color(0xFFFF1744),
          ),
        ),
      ),
    ],
  ),
),
        
        
      
const SizedBox(height: 18),

        const Text(
          "You haven't joined any contest yet!",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0D2B63),
          ),
        ),

        const SizedBox(height: 8),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Join a contest to compete and win exciting prizes.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF6B7280),
            ),
          ),
        ),

       
      ],
    ),
  );
}
          final matchNames = <String>[];

            for (final contest in sourceContests) {
  final matchName =
      (contest['match'] ?? '').toString();
  if (matchName.isNotEmpty &&
      !matchNames.contains(matchName)) {
    matchNames.add(matchName);
  }
}

return ListView.builder(
  padding: const EdgeInsets.all(12),
  itemCount: matchNames.length,
  itemBuilder: (context, index) {
    final matchName = matchNames[index];

    final matchContests = sourceContests
        .where(
          (c) =>
              (c['match'] ?? '').toString() ==
              matchName,
        )
        .toList();
final linkedMatch = matchContests.isNotEmpty
    ? findLinkedMatch(matchContests.first)
    : null;

final matchDay = linkedMatch?.startTime;
final now = DateTime.now();

String dayTitle = '';
String fullDate = '';

if (matchDay != null) {
  final today = DateTime(now.year, now.month, now.day);
  final thisDay =
      DateTime(matchDay.year, matchDay.month, matchDay.day);

  final diff = today.difference(thisDay).inDays;

  if (diff == 0) {
    dayTitle = 'TODAY';
  } else if (diff == 1) {
    dayTitle = 'YESTERDAY';
  } else {
    dayTitle = 'DATE';
  }

  const months = [
    'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
    'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
  ];

  fullDate =
      '${matchDay.day} ${months[matchDay.month - 1]} ${matchDay.year}';
}
    String format = '';
String flag1 = '';
String flag2 = '';
for (final m in adminMatches.value) {
  final adminMatchName =
      '${m['team1'] ?? ''} vs ${m['team2'] ?? ''}'
          .trim()
          .toLowerCase();

  if (adminMatchName == matchName.trim().toLowerCase()) {
    format = (m['matchFormat'] ?? '').toString();
    flag1 = (m['team1Logo'] ?? '').toString();
flag2 = (m['team2Logo'] ?? '').toString();
    break;
  }
}
final teams = matchName.split(
  RegExp(r'\s+vs\s+', caseSensitive: false),
);

final team1Name =
    teams.isNotEmpty ? teams[0].trim() : '';

final team2Name =
    teams.length > 1 ? teams[1].trim() : '';

String makeShortName(String name) {
  final words = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((e) => e.isNotEmpty)
      .toList();

  if (words.isEmpty) return '';

  if (words.length == 1) {
    final word = words.first.toUpperCase();

    return word.length <= 3
        ? word
        : word.substring(0, 3);
  }

  return words
      .take(3)
      .map((e) => e[0].toUpperCase())
      .join();
}



final team1Short = makeShortName(team1Name);
final team2Short = makeShortName(team2Name);


    
    return Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    if (matchDay != null)
      Container(
        height: 44,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFF4D6D),
              Color(0xFFFF8FA3),
              Color(0xFFFFD6DE),
              Color(0xFFFFF1F4),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 62,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFFD9043D),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
              ),
              child: const Icon(
                Icons.calendar_month,
                color: Colors.white,
                size: 30,
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
              ),
              alignment: Alignment.centerLeft,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dayTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    fullDate,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

    Card(
  color: const Color(0xFFFFD2B8),
  margin: const EdgeInsets.only(bottom: 12),
  child: ListTile(
                      title: Text.rich(
  TextSpan(
    children: [
      TextSpan(
        text: '$flag1 $team1Short vs $team2Short $flag2',
        style: const TextStyle(
          color: Color(0xFF3D2B2B),
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      if (format.isNotEmpty)
        TextSpan(
          text: '   •   $format',
          style: const TextStyle(
            color: Color(0xFFC65300),
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
    ],
  ),
),
                      subtitle: Text(
  '${matchContests.length} Joined '
  'Contest${matchContests.length == 1 ? '' : 's'}',
  style: const TextStyle(
    color: Color(0xFF8E4753),
fontWeight: FontWeight.w700,
  ),
),
                      trailing:
                          const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                MyMatchContestsPage(
                              matchName: matchName,
                              contests: matchContests,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
      ],
);
                },
              );
            }

            return TabBarView(
              children: [
                contestList(
                  visibleContests,
                  'No Contests Joined',
                ),
                Column(
                  children: [
                    Padding(
  padding: const EdgeInsets.symmetric(vertical: 10),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: const [
      Text(
        '⚠️',
        style: TextStyle(fontSize: 18),
      ),
      SizedBox(width: 7),
      Text(
        'This chat/file is archived for only 5 days',
        style: TextStyle(
          color: Color(0xFF2F3A4A),
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  ),
),
                    Expanded(
                      child: contestList(
                        archivedContests,
                        'No Archived Contests',
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

    class MyMatchContestsPage extends StatelessWidget {
  final String matchName;
  final List<Map<String, dynamic>> contests;

  const MyMatchContestsPage({
    super.key,
    required this.matchName,
    required this.contests,
  });

  @override
  Widget build(BuildContext context) {
    final teams = matchName.split(
  RegExp(r'\s+vs\s+', caseSensitive: false),
);

final team1Name =
    teams.isNotEmpty ? teams[0].trim() : '';

final team2Name =
    teams.length > 1 ? teams[1].trim() : '';

String makeShortName(String name) {
  final words = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((e) => e.isNotEmpty)
      .toList();

  if (words.isEmpty) return '';

  if (words.length == 1) {
    final word = words.first.toUpperCase();
    return word.length <= 3
        ? word
        : word.substring(0, 3);
  }

  return words
      .take(3)
      .map((e) => e[0].toUpperCase())
      .join();
}



final team1Short = makeShortName(team1Name);
final team2Short = makeShortName(team2Name);

String flag1 = '';
String flag2 = '';
String format = '';

for (final m in adminMatches.value) {
  final adminMatchName =
      '${m['team1'] ?? ''} vs ${m['team2'] ?? ''}'
          .trim()
          .toLowerCase();

  if (adminMatchName == matchName.trim().toLowerCase()) {
    format = (m['matchFormat'] ?? '').toString();
    flag1 = (m['team1Logo'] ?? '').toString();
flag2 = (m['team2Logo'] ?? '').toString();
    break;
  }
}
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0ED),
      appBar: AppBar(
        title: Text.rich(
  TextSpan(
    children: [
      TextSpan(
        text:
            '$flag1 $team1Short vs $team2Short $flag2',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF222222),
        ),
      ),
      if (format.isNotEmpty)
        TextSpan(
          text: '   •   $format',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFFE85D5D),
          ),
        ),
    ],
  ),
),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: contests.length,
        itemBuilder: (context, index) {
          final contest = contests[index];

          final contestTitle =
              (contest['contestName'] ?? '') == 'Head to Head' &&
                      (contest['winningType'] ?? '')
                          .toString()
                          .trim()
                          .isNotEmpty
                  ? 'Head to Head • ${contest['winningType']}'
                  : '${contest['contestName'] ?? 'Contest'}';
final lowerTitle = contestTitle.toLowerCase();

final Color contestColor =
    lowerTitle.contains('winner takes all')
        ? const Color(0xFFFFE5E5)
        : lowerTitle.contains('rank wise')
            ? const Color(0xFFE8F5E9)
            : lowerTitle.contains('mega')
                ? const Color(0xFFF1E8FF)
                : lowerTitle.contains('small')
                    ? const Color(0xFFE7F3FF)
                    : const Color(0xFFFFF0ED);
            return Card(
  color: contestColor,
  elevation: 1.5,
  margin: const EdgeInsets.only(bottom: 10),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
    side: const BorderSide(
      color: Color(0xFFD8C9C2),
      width: 1.2,
    ),
  ),
  clipBehavior: Clip.antiAlias,
  child: ListTile(
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 14,
      vertical: 4,
    ),
              title: Text(
  contestTitle,
  style: const TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: Color(0xFF2A1F1F),
  ),
),
              subtitle: Text(
                contest['joinedTeamName'] ?? 'Team 1',
              ),
              trailing: Container(
  padding: const EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 6,
  ),
  decoration: BoxDecoration(
    color: Colors.white.withOpacity(0.75),
    borderRadius: BorderRadius.circular(14),
    border: Border.all(
      color: const Color(0xFFD8C9C2),
    ),
  ),
  child: Text(
    '₹${contest['entryFee'] ?? 0}',
    style: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 14,
    ),
  ),
),
    onTap: () {
  MatchModel? selectedMatch;

                for (final m in joinedMatches.value) {
                  if (m.team1 == contest['team1'] &&
                      m.team2 == contest['team2']) {
                    selectedMatch = m;
                    break;
                  }
                }

                if (selectedMatch == null) return;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MyMatchDetailPage(
                      match: selectedMatch!,
                      contest: contest,
                      allowSettlement: false,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}  

// ================= MY MATCHES =================
class MyMatchesPage extends StatefulWidget {
  const MyMatchesPage({super.key});

  @override
  State<MyMatchesPage> createState() => _MyMatchesPageState();
}

class _MyMatchesPageState extends State<MyMatchesPage> {
Timer? matchesTimer;
  DateTime? _parseMatchDateTime(String date, String time) {
  try {
    final dateParts = date.trim().split('/');
    if (dateParts.length != 3) return null;

    final day = int.parse(dateParts[0]);
    final month = int.parse(dateParts[1]);
    final year = int.parse(dateParts[2]);

    final cleanTime = time.trim().toUpperCase();
    final isPM = cleanTime.contains('PM');
    final isAM = cleanTime.contains('AM');

    final onlyTime = cleanTime
        .replaceAll('AM', '')
        .replaceAll('PM', '')
        .trim();

    final timeParts = onlyTime.split(':');

    int hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    if (isPM && hour != 12) hour += 12;
    if (isAM && hour == 12) hour = 0;

    return DateTime(year, month, day, hour, minute);
  } catch (_) {
    return null;
  }
}
  @override
void initState() {
  super.initState();

  matchesTimer = Timer.periodic(
    const Duration(seconds: 1),
    (_) {
      if (mounted) {
        setState(() {});
      }
    },
  );
}
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
  length: 4,
  child: Scaffold(
      appBar: AppBar(
  title: const Text('My Matches'),
  bottom: TabBar(
  indicatorColor: Color(0xFFA94442),
  labelColor: Color(0xFF2F3A4A),
  unselectedLabelColor: Color(0xFF5F6670),
  labelStyle: TextStyle(
    fontWeight: FontWeight.w700,
  ),
  unselectedLabelStyle: TextStyle(
    fontWeight: FontWeight.w600,
  ),
  labelPadding: const EdgeInsets.symmetric(horizontal: 4),
    tabs: [
  Tab(
    child: SizedBox(
      width: 88,
      height: 42,
      child: DecoratedBox(
        decoration: BoxDecoration(
  color: const Color(0xFF2196F3),
  borderRadius: BorderRadius.circular(14),
  
),
        child: const Center(
          child: Text(
  'Upcoming',
  style: TextStyle(color: Colors.white),
),
        ),
      ),
    ),
  ),

  Tab(
    child: SizedBox(
      width: 88,
      height: 42,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF2E7D32),
          borderRadius: BorderRadius.circular(14),
          
        ),
        child: const Center(
          child: Text(
  'Live',
  style: TextStyle(color: Colors.white),
),
        ),
      ),
    ),
  ),

  Tab(
    child: SizedBox(
      width: 88,
      height: 42,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFFFB300),
          borderRadius: BorderRadius.circular(14),
          
        ),
        child: const Center(
         child: Text(
  'Completed',
  style: TextStyle(
    color: Color(0xFF212121),
    fontWeight: FontWeight.w700,
  ),
),
        ),
      ),
    ),
  ),

  Tab(
    child: SizedBox(
      width: 88,
      height: 42,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF673AB7),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(
          child: Text(
  'Archived',
  style: TextStyle(color: Colors.white),
),
        ),
      ),
    ),
  ),
],
),
        ),
      body: ValueListenableBuilder<List<MatchModel>>(
  valueListenable: joinedMatches,
  builder: (context, matches, _) {
    final syncedMatches = matches.map((joinedMatch) {
  Map<String, dynamic>? adminMatch;

  for (final m in adminMatches.value) {
    if (m['team1'] == joinedMatch.team1 &&
        m['team2'] == joinedMatch.team2) {
      adminMatch = m;
      break;
    }
  }

  if (adminMatch == null) {
    return joinedMatch;
  }

  final newStartTime = _parseMatchDateTime(
  adminMatch['date'] ?? '',
  adminMatch['time'] ?? '',
) ?? joinedMatch.startTime;

final newDurationMinutes = int.tryParse(
      adminMatch['durationMinutes'] ?? '',
    ) ??
    joinedMatch.liveDuration.inMinutes;

return MatchModel(
  team1: adminMatch['team1'] ?? joinedMatch.team1,
  team2: adminMatch['team2'] ?? joinedMatch.team2,
  team1Flag: adminMatch['team1Logo'] ?? joinedMatch.team1Flag,
  team2Flag: adminMatch['team2Logo'] ?? joinedMatch.team2Flag,
  title: joinedMatch.title,
  matchFormat: adminMatch['matchFormat'] ?? joinedMatch.matchFormat,
  time: adminMatch['time'] ?? joinedMatch.time,
  status: joinedMatch.status,
  userPoints: joinedMatch.userPoints,
  startTime: newStartTime ?? joinedMatch.startTime,
  liveDuration: Duration(minutes: newDurationMinutes),
  winner: joinedMatch.winner,
  team1Score: joinedMatch.team1Score,
  team2Score: joinedMatch.team2Score,
  userRank: joinedMatch.userRank,
  entryFee: joinedMatch.entryFee,
  prizePool: joinedMatch.prizePool,
  contestName: joinedMatch.contestName,
  contestSpots: joinedMatch.contestSpots,
  team1Players:
      adminMatch['team1Players'] ?? joinedMatch.team1Players,
  team2Players:
      adminMatch['team2Players'] ?? joinedMatch.team2Players,
);
}).toList();
    

    final upcomingMatches = syncedMatches
    .where((match) => match.currentStatus == 'UPCOMING')
    .toList();

final liveMatches = syncedMatches
    .where((match) => match.currentStatus == 'LIVE')
    .toList();

final completedMatches = syncedMatches.where((match) {
  if (match.currentStatus != 'COMPLETED') {
    return false;
  }

  final completionTime =
      match.completedAt ??
      match.startTime?.add(match.liveDuration);

  if (completionTime == null) {
    return true;
  }
final archiveAt =
    completionTime.add(const Duration(hours: 24));

return DateTime.now().isBefore(archiveAt);
  

  
}).toList();
final archivedMatches = syncedMatches.where((match) {
  if (match.currentStatus != 'COMPLETED') {
    return false;
  }

  final completionTime =
      match.completedAt ??
      match.startTime?.add(match.liveDuration);

  if (completionTime == null) {
    return false;
  }
final archiveAt =
    completionTime.add(const Duration(hours: 24));

final deleteAt =
    archiveAt.add(const Duration(days: 5));
  

  final now = DateTime.now();

  return !now.isBefore(archiveAt) &&
      now.isBefore(deleteAt);
}).toList();
    Widget matchList(List<MatchModel> list, String emptyText) {
      if (list.isEmpty) {
        return Center(
          child: Text(
            emptyText,
            style: const TextStyle(fontSize: 18),
          ),
        );
      }
list.sort((a, b) {
  final aTime = a.startTime ?? DateTime(2000);
  final bTime = b.startTime ?? DateTime(2000);
  return bTime.compareTo(aTime);
});
      return ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final match = list[index];
final remaining = match.startTime?.difference(DateTime.now());
final mins = remaining == null ? 0 : remaining.inMinutes;
final secs = remaining == null ? 0 : remaining.inSeconds % 60;
          final matchDate = match.time.split('•').isNotEmpty
    ? match.time.split('•')[0].trim()
    : '';

final matchTime = match.time.split('•').length > 1
    ? match.time.split('•')[1].trim()
    : '';
         final team1Words = match.team1.trim().split(RegExp(r'\s+'));
final team1Short = team1Words.length >= 2
    ? team1Words.map((e) => e[0].toUpperCase()).join()
    : (match.team1.trim().length <= 3
        ? match.team1.trim().toUpperCase()
        : match.team1.trim().substring(0, 3).toUpperCase());

final team2Words = match.team2.trim().split(RegExp(r'\s+'));
final team2Short = team2Words.length >= 2
    ? team2Words.map((e) => e[0].toUpperCase()).join()
    : (match.team2.trim().length <= 3
        ? match.team2.trim().toUpperCase()
        : match.team2.trim().substring(0, 3).toUpperCase());
final matchDay = match.startTime;
final previousDay =
    index > 0 ? list[index - 1].startTime : null;

final showDateHeader = index == 0 ||
    matchDay == null ||
    previousDay == null ||
    matchDay.day != previousDay.day ||
    matchDay.month != previousDay.month ||
    matchDay.year != previousDay.year;

final today = DateTime.now();

final isToday = matchDay != null &&
    matchDay.day == today.day &&
    matchDay.month == today.month &&
    matchDay.year == today.year;

final dateHeaderText =
    isToday ? 'TODAY' : matchDate;
          return Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    if (showDateHeader)
      Container(
        margin: const EdgeInsets.only(
          bottom: 8,
          top: 4,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFFFE3E3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '📅 $dateHeaderText'
          '${matchTime.isNotEmpty ? ' • $matchTime' : ''}',
          style: const TextStyle(
            color: Color(0xFFA94442),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),

    Card(
            color: match.currentStatus == 'UPCOMING'
    ? const Color(0xFFD9E8FF)
    : match.currentStatus == 'LIVE'
        ? const Color(0xFFBFE7C8)
        : match.currentStatus == 'COMPLETED'
            ? const Color(0xFFF6E3A6)
            : const Color(0xFFE2D1F4),
            
            child: ListTile(
  contentPadding: const EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 5,
  ),
leading: const CircleAvatar(
  radius: 25,
  backgroundColor: Color(0xFFFFD6D6),
  child: Icon(
    Icons.sports_cricket,
    color: Color(0xFF1565C0),
  ),
),

title: Row(
  children: [
    Text(
  match.team1Flag,
  style: const TextStyle(fontSize: 20),
),

    const SizedBox(width: 5),

    Text(
      team1Short,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    ),

    const Text(
      '  vs  ',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: Color(0xFF777777),
      ),
    ),

    Text(
      team2Short,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    ),

    const SizedBox(width: 5),

    Text(
  match.team2Flag,
  style: const TextStyle(fontSize: 20),
),

    const Spacer(),

    Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        match.matchFormat,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Color(0xFF3949AB),
        ),
      ),
    ),
  ],
),
  
   

  subtitle: Padding(
    padding: const EdgeInsets.only(top: 7),
    child: Text(
      '📅 $matchDate  •  $matchTime\n'
      '${match.currentStatus == 'UPCOMING'
          ? '⏳ Starts in ${mins}:${secs.toString().padLeft(2, '0')}'
          : match.currentStatus == 'LIVE'
              ? '🔴 LIVE'
              : '🏆 Completed'}',
      style: const TextStyle(
        fontSize: 14,
        height: 1.5,
      ),
    ),
  ),

  trailing: const Icon(
    Icons.chevron_right,
    size: 30,
  ),
              onTap: () {
              
                Navigator.push(
                  context,
                  MaterialPageRoute(
  builder: (_) =>
      match.currentStatus == 'LIVE' ||
              match.currentStatus == 'COMPLETED'
       ? HomePlayerStatsPage(match: match)
          : MyMatchDetailPage(
              match: match,
              allowSettlement: false,
            ),
),
                );
              },
            ),
          ),
],
);
        },
      );
    }

    return TabBarView(
      children: [
        // UPCOMING
        matchList(
          upcomingMatches,
          'कोई Upcoming match नहीं है',
        ),

        // LIVE
        matchList(
          liveMatches,
          'अभी कोई Live match नहीं है',
        ),

        // COMPLETED
        matchList(
          completedMatches,
          'कोई Completed match नहीं है',
        ),
        // ARCHIVED
Column(
  children: [
    const Padding(
      padding: EdgeInsets.all(12),
      child: Text(
        '⚠️ This chat/file is archived for only 5 days',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    ),
    Expanded(
      child: matchList(
        archivedMatches,
        'कोई Archived match नहीं है',
      ),
    ),
  ],
),
      ],
    );
  },
),
        ),
      );
    }
}

class MyMatchDetailPage extends StatefulWidget {
  final MatchModel match;
final bool allowSettlement;
final Map<String, dynamic>? contest;
const MyMatchDetailPage({
  super.key,
  required this.match,
  this.contest,
  this.allowSettlement = false,
});

  @override
  State<MyMatchDetailPage> createState() => _MyMatchDetailPageState();
}
class _MyMatchDetailPageState extends State<MyMatchDetailPage> {
Timer? liveUpdateTimer;
String _shortTeamName(String name) {
  final words = name.trim().split(RegExp(r'\s+'));

  if (words.length == 1) {
    return words.first.length <= 3
        ? words.first.toUpperCase()
        : words.first.substring(0, 3).toUpperCase();
  }

  return words
      .map((word) => word.isNotEmpty ? word[0].toUpperCase() : '')
      .join();
}
late double livePoints;
late int team1LiveScore;
late int team2LiveScore;
late int team1LiveWickets;
late int team2LiveWickets;
  
  double _contestWinningForRank(int rank) {
  if (widget.contest == null) return 0.0;

  final rawSlabs = widget.contest!['prizeSlabs'];

  if (rawSlabs is List) {
    for (final rawSlab in rawSlabs) {
      if (rawSlab is! Map) continue;

      final from =
          int.tryParse('${rawSlab['from'] ?? ''}') ?? 0;

      final to =
          int.tryParse('${rawSlab['to'] ?? ''}') ?? from;

      final prize = double.tryParse(
            '${rawSlab['amount'] ?? rawSlab['prize'] ?? ''}',
          ) ??
          0.0;

      if (rank >= from && rank <= to) {
        return prize;
      }
    }
  }

  // पुराने contest में slabs न हों तो Rank #1 को Prize Pool
  if (rank == 1) {
    return ((widget.contest!['prizePool'] ?? 0) as num)
        .toDouble();
  }

  return 0.0;
}
  double _getContestTeamPoints([
  Map<String, dynamic>? targetContest,
]) {
  final contest = targetContest ?? widget.contest;

  if (contest == null ||
      contest['selectedPlayers'] == null ||
      contest['matchKey'] == null) {
    return widget.match.userPoints.toDouble();
  }

  final players =
      List<Player>.from(contest['selectedPlayers'] as List);

  String contestMatchKey =
    contest['matchKey']?.toString() ?? '';

Map<String, Map<String, int>> matchStats =
    savedPlayerStats[contestMatchKey] ?? {};

if (matchStats.isEmpty) {
  for (final entry in savedPlayerStats.entries) {
    final key = entry.key.toLowerCase();

    if (key.contains(widget.match.team1.toLowerCase()) &&
        key.contains(widget.match.team2.toLowerCase())) {
      contestMatchKey = entry.key;
      matchStats = entry.value;
      break;
    }
  }
}

  final captainName =
      contest['captainName']?.toString() ?? '';

  final viceCaptainName =
      contest['viceCaptainName']?.toString() ?? '';

  double total = 0;

  for (final player in players) {
    Map<String, int>? stats;

    for (final entry in matchStats.entries) {
      if (entry.key.split('|').first.trim() ==
          player.name.trim()) {
        stats = entry.value;
        break;
      }
    }

    final runs = stats?['runs'] ?? 0;
    final fours = stats?['fours'] ?? 0;
    final sixes = stats?['sixes'] ?? 0;
    final wickets = stats?['wickets'] ?? 0;
    final catches = stats?['catches'] ?? 0;

    final basePoints =
        runs +
        (fours * 2) +
        (sixes * 4) +
        (wickets * 30) +
        (catches * 10);

    double points = basePoints.toDouble();

    if (player.name == captainName) {
      points *= 2;
    } else if (player.name == viceCaptainName) {
      points *= 1.5;
    }

    total += points;
  }

  return total;
}
@override
void initState() {
  super.initState();
  adminMatches.addListener(_syncContestLatestData);
  joinedMatches.addListener(_syncContestLatestData);
  

  livePoints = _getContestTeamPoints();

final latestMatches = joinedMatches.value.where(
  (m) =>
      m.team1 == widget.match.team1 &&
      m.team2 == widget.match.team2,
).toList();

if (latestMatches.isNotEmpty) {
  final latestMatch = latestMatches.first;

  team1LiveScore = latestMatch.team1Score ?? 0;
  team2LiveScore = latestMatch.team2Score ?? 0;
  livePoints = _getContestTeamPoints();
  team1LiveWickets = latestMatch.team1Wickets ?? 0;
team2LiveWickets = latestMatch.team2Wickets ?? 0;
} else {
  team1LiveScore = widget.match.team1Score ?? 0;
  team2LiveScore = widget.match.team2Score ?? 0;
  team1LiveWickets = widget.match.team1Wickets ?? 0;
team2LiveWickets = widget.match.team2Wickets ?? 0;
}


}

void _syncContestLatestData() {
  if (!mounted) return;

  final latestAdminMatches = adminMatches.value.where(
    (m) =>
        m['team1'] == widget.match.team1 &&
        m['team2'] == widget.match.team2,
  ).toList();

  final latestJoinedMatches = joinedMatches.value.where(
    (m) =>
        m.team1 == widget.match.team1 &&
        m.team2 == widget.match.team2,
  ).toList();

  setState(() {
    if (latestAdminMatches.isNotEmpty) {
      final m = latestAdminMatches.first;

      team1LiveScore =
          ((m['team1Score'] ?? team1LiveScore) as num).toInt();

      team2LiveScore =
          ((m['team2Score'] ?? team2LiveScore) as num).toInt();

      team1LiveWickets = latestJoinedMatches.isNotEmpty
    ? (latestJoinedMatches.first.team1Wickets ?? 0)
    : ((m['team1Wickets'] ?? team1LiveWickets) as num).toInt();

team2LiveWickets = latestJoinedMatches.isNotEmpty
    ? (latestJoinedMatches.first.team2Wickets ?? 0)
    : ((m['team2Wickets'] ?? team2LiveWickets) as num).toInt();
    } else if (latestJoinedMatches.isNotEmpty) {
      final m = latestJoinedMatches.first;

      team1LiveScore = m.team1Score ?? 0;
      team2LiveScore = m.team2Score ?? 0;
      team1LiveWickets = m.team1Wickets ?? 0;
      team2LiveWickets = m.team2Wickets ?? 0;
    }

     livePoints = _getContestTeamPoints();
});

// FINAL stats आने के बाद points को दो बार fresh करो,
// फिर ही winning/history settle करो
Future.delayed(const Duration(seconds: 2), () {
  if (!mounted) return;

  setState(() {
    livePoints = _getContestTeamPoints();
  });

  Future.delayed(const Duration(seconds: 1), () {
    if (!mounted) return;

    setState(() {
      livePoints = _getContestTeamPoints();
    });

    autoSettleWinning();
  });
});
}
void autoSettleWinning() {
  if (!widget.allowSettlement) return;
  final latestAdminMatches = adminMatches.value.where(
  (m) =>
      m['team1'] == widget.match.team1 &&
      m['team2'] == widget.match.team2,
).toList();

final bool finalScoreUpdated =
    latestAdminMatches.isNotEmpty &&
    latestAdminMatches.first['finalScoreUpdated'] == 'true';

if (!finalScoreUpdated) return;

final String currentMatchKey =
    (widget.contest?['matchKey'] ?? '').toString();

final sameMatchContests =
    joinedContests.value.where((c) {
  final String contestMatchKey =
      (c['matchKey'] ?? '').toString();

  if (currentMatchKey.isNotEmpty) {
    return contestMatchKey == currentMatchKey;
  }

  return c['team1'] == widget.match.team1 &&
      c['team2'] == widget.match.team2;
}).toList();

if (sameMatchContests.isEmpty) return;

for (final contest in sameMatchContests) {


  final String contestName =
      (contest['contestName'] ?? widget.match.contestName).toString();

  final int contestSpots =
      ((contest['spots'] ?? widget.match.contestSpots) as num).toInt();

  final double contestPrizePool =
      ((contest['prizePool'] ?? widget.match.prizePool) as num).toDouble();

  // इसी contest का leaderboard
  final double contestPoints =
    _getContestTeamPoints(contest);
    

final List<Map<String, dynamic>> leaderboard =
    <Map<String, dynamic>>[
  {
    'name': 'Cricket King',
    'points': 742.0,
  },

  if (contestSpots != 2)
    {
      'name': 'Super XI',
      'points': 711.0,
    },

  {
    'name': 'You',
    'points': contestPoints.toDouble(),
  },
];

leaderboard.sort(
  (a, b) => (b['points'] as double)
      .compareTo(a['points'] as double),
);

final int rank =
    leaderboard.indexWhere(
      (item) => item['name'] == 'You',
    ) +
    1;

  // Match + Contest + Team की unique winning key
final String teamKey =
    (contest['teamName'] ??
            contest['selectedTeam'] ??
            contest['teamIndex'] ??
            contest['teamId'] ??
            '')
        .toString();

final String contestId =
    (contest['contestId'] ??
            contest['id'] ??
            '')
        .toString()
        .trim();

final String matchKey =
    (contest['matchKey'] ??
            '${widget.match.team1}-${widget.match.team2}')
        .toString();

final String settlementWinningType =
    (contest['h2hWinningType'] ??
            contest['winningType'] ??
            '')
        .toString()
        .trim();

final String claimKey = contestId.isNotEmpty
    ? '$matchKey-$contestId-$contestName-$settlementWinningType-$teamKey'
    : '$matchKey-$contestName-$settlementWinningType-$teamKey';

String shortWinningTeamName(String name) {
  final parts =
      name.trim().split(RegExp(r'\s+'));

  if (parts.length == 1) {
    final word = parts.first.toUpperCase();

    return word.length <= 3
        ? word
        : word.substring(0, 3);
  }

  return parts
      .take(3)
      .map((e) => e[0].toUpperCase())
      .join();
}

final legacyMatchDescription =
    '${widget.match.team1} vs ${widget.match.team2}';

final matchDescription =
    '${widget.match.team1Flag} '
    '${shortWinningTeamName(widget.match.team1)} '
    'vs '
    '${shortWinningTeamName(widget.match.team2)} '
    '${widget.match.team2Flag} '
    '• ${widget.match.matchFormat}';
  
  Map<String, dynamic> makeWinningHistoryItem({
  required double amount,
  Map<String, dynamic>? oldItem,
}) {
    final historyNow = DateTime.now();
  final oldTxnNumber =
      (oldItem?['txnNumber'] ?? '')
          .toString()
          .trim();

  final oldDateTime =
      (oldItem?['dateTime'] ?? '')
          .toString()
          .trim();

  return {
    if (oldItem != null) ...oldItem,

    'title': 'Winning',

    'txnNumber': oldTxnNumber.isNotEmpty
        ? oldTxnNumber
        : generateTxnNumber('WINNING'),

    'subtitle': contestName,

    'winningType': settlementWinningType,

    'rank': rank,

    'claimKey': claimKey,

    'contestId': contestId,

    'teamKey': teamKey,

    'description': matchDescription,

    'dateTime': oldDateTime.isNotEmpty
    ? oldDateTime
    : '${historyNow.day.toString().padLeft(2, '0')}/'
        '${historyNow.month.toString().padLeft(2, '0')}/'
        '${historyNow.year}  '
        '${historyNow.hour.toString().padLeft(2, '0')}:'
        '${historyNow.minute.toString().padLeft(2, '0')}',

    'amount': amount,
  };
}
  
// पुराने duplicate Winning record को एक बार हटाओ
if (contestId.isEmpty) {
  final legacyIndex =
    transactionHistory.value.indexWhere((item) =>
        item['title'] == 'Winning' &&
        (item['claimKey'] ?? '').toString().trim().isEmpty &&
        item['subtitle'] == contestName &&
        (
  item['description'] == matchDescription ||
  item['description'] == legacyMatchDescription
) &&
        (item['winningType'] ?? '').toString().trim() ==
            (contest['h2hWinningType'] ??
                    contest['winningType'] ??
                    '')
                .toString()
                .trim() &&
        item['rank'] == null);

final rankedIndex =
    transactionHistory.value.indexWhere((item) =>
        item['title'] == 'Winning' &&
        item['subtitle'] == contestName &&
        (
  item['description'] == matchDescription ||
  item['description'] == legacyMatchDescription
) &&
        (item['winningType'] ?? '').toString().trim() ==
            (contest['h2hWinningType'] ??
                    contest['winningType'] ??
                    '')
                .toString()
                .trim() &&
        item['rank'] != null);

  if (legacyIndex != -1 && rankedIndex != -1) {
    final history =
        List<Map<String, dynamic>>.from(
            transactionHistory.value);

    final duplicateAmount =
        (history[legacyIndex]['amount'] as num?)
                ?.toDouble() ??
            0.0;

    history.removeAt(legacyIndex);
    transactionHistory.value = history;

    walletBalance.value -= duplicateAmount;
  }
}
final existingWinningIndex =
    transactionHistory.value.indexWhere((item) {
  final savedClaimKey =
      (item['claimKey'] ?? '').toString().trim();

  if (savedClaimKey.isNotEmpty) {
    return savedClaimKey == claimKey;
  }

  // पुराने records में claimKey नहीं था
  if (contestId.isEmpty) {
  final savedWinningType =
      (item['winningType'] ?? '').toString().trim();

  final currentWinningType =
      (contest['h2hWinningType'] ??
              contest['winningType'] ??
              '')
          .toString()
          .trim();

  return item['title'] == 'Winning' &&
      item['subtitle'] == contestName &&
      (
  item['description'] == matchDescription ||
  item['description'] == legacyMatchDescription
) &&
      savedWinningType == currentWinningType;
}

  return false;
});
final rawSlabs = contest['prizeSlabs'];
double winningAmount = 0.0;

if (rawSlabs is List) {
  for (final slab in rawSlabs) {
    if (slab is Map) {
      final from =
          int.tryParse('${slab['from']}');
      final to =
          int.tryParse('${slab['to']}');
      final amount =
          double.tryParse('${slab['amount']}');

      if (from != null &&
          to != null &&
          amount != null &&
          rank >= from &&
          rank <= to) {
        winningAmount = amount;
        break;
      }
    }
  }
}

// अगर Prize Slab नहीं है तो Rank #1 = Prize Pool
final hasPrizeSlabs =
    rawSlabs is List && rawSlabs.isNotEmpty;

if (!hasPrizeSlabs && rank == 1) {
  winningAmount = contestPrizePool;
}

// पहले से Winning History है तो उसे सही/update करो
if (existingWinningIndex != -1) {
  final history =
      List<Map<String, dynamic>>.from(
        transactionHistory.value,
      );

  final oldItem =
      history[existingWinningIndex];

  final double oldAmount =
      (oldItem['amount'] as num?)?.toDouble() ?? 0.0;

  final int oldRank =
      (oldItem['rank'] as num?)?.toInt() ?? 0;

  // Result पहले से सही है:
  // पैसा दोबारा नहीं जोड़ना,
  // सिर्फ display + txn number सही करना
  if (oldRank == rank &&
      oldAmount == winningAmount) {

    history[existingWinningIndex] =
    makeWinningHistoryItem(
  amount: winningAmount,
  oldItem: oldItem,
);

    transactionHistory.value = history;

    final updated =
        Set<String>.from(claimedWinnings.value);

    updated.add(claimKey);
    claimedWinnings.value = updated;

    continue;
  }

  // Result बदला है तो wallet में सिर्फ difference लगेगा
  walletBalance.value +=
      winningAmount - oldAmount;

  if (winningAmount > 0) {
    history[existingWinningIndex] =
    makeWinningHistoryItem(
  amount: winningAmount,
  oldItem: oldItem,
);
  } else {
    history.removeAt(existingWinningIndex);
  }

  transactionHistory.value = history;
}

// कोई पुरानी Winning entry नहीं है तो नई बनाओ
else if (winningAmount > 0) {
  walletBalance.value += winningAmount;

  transactionHistory.value = [
  ...transactionHistory.value,
  makeWinningHistoryItem(
    amount: winningAmount,
  ),
];
  
}

// अब current सही result को settled mark करो
final updated =
    Set<String>.from(claimedWinnings.value);

updated.add(claimKey);
claimedWinnings.value = updated;
  }
}
@override
void dispose() {
  adminMatches.removeListener(_syncContestLatestData);
  joinedMatches.removeListener(_syncContestLatestData);

  liveUpdateTimer?.cancel();
  super.dispose();
}

  @override
  Widget build(BuildContext context) {
    final winningType =
    (widget.contest?['winningType'] ?? '').toString().trim();

final contestName =
    (widget.contest?['contestName'] ??
            widget.contest?['name'] ??
            '')
        .toString();

final detailTitle =
    contestName == 'Head to Head' && winningType.isNotEmpty
        ? '$contestName • $winningType'
        : contestName;
    final contestSpots =
    ((widget.contest?['spots'] ?? widget.match.contestSpots) as num)
        .toInt();

final latestAdminMatches = adminMatches.value.where(
  (m) =>
      m['team1'] == widget.match.team1 &&
      m['team2'] == widget.match.team2,
).toList();

final latestJoinedMatches = joinedMatches.value.where(
  (m) =>
      m.team1 == widget.match.team1 &&
      m.team2 == widget.match.team2,
).toList();

final bool adminDurationCompleted =
    latestAdminMatches.isNotEmpty &&
    widget.match.startTime != null &&
    DateTime.now().isAfter(
      widget.match.startTime!.add(
        Duration(
          minutes: int.tryParse(
                (latestAdminMatches.first['durationMinutes'] ?? '')
                    .toString(),
              ) ??
              widget.match.liveDuration.inMinutes,
        ),
      ),
    );

final bool adminCompleted =
    adminDurationCompleted ||
    (latestAdminMatches.isNotEmpty &&
        (latestAdminMatches.first['currentStatus'] ??
                latestAdminMatches.first['status']) ==
            'COMPLETED');

final bool joinedCompleted =
    latestJoinedMatches.isNotEmpty &&
    latestJoinedMatches.first.currentStatus == 'COMPLETED';
final bool finalScoreUpdated =
    latestAdminMatches.isNotEmpty &&
    latestAdminMatches.first['finalScoreUpdated'] == 'true';
final bool showMatchWinner =
    widget.contest == null && finalScoreUpdated;

final String matchWinnerText =
    (widget.match.team1Score ?? 0) > (widget.match.team2Score ?? 0)
        ? 'Winner: ${widget.match.team1} 🏆'
        : (widget.match.team2Score ?? 0) > (widget.match.team1Score ?? 0)
            ? 'Winner: ${widget.match.team2} 🏆'
            : 'Match Tied';
final bool contestCompleted =
    (adminCompleted ||
        joinedCompleted ||
        widget.match.currentStatus == 'COMPLETED') &&
    finalScoreUpdated;
    final bool showFinalRanks = contestCompleted;
   final leaderboard = <Map<String, dynamic>>[
  {
    'name': 'Cricket King',
    'points': showFinalRanks ? 742.0 : 0.0,
  },

  if (contestSpots != 2)
    {
      'name': 'Super XI',
      'points': showFinalRanks ? 711.0 : 0.0,
    },

  {
    'name': 'You',
    'points': showFinalRanks  ? livePoints.toDouble() : 0.0,
  },
];

if (showFinalRanks) {
  leaderboard.sort(
    (a, b) => (b['points'] as double)
        .compareTo(a['points'] as double),
  );
}

final int calculatedLiveRank = 
    showFinalRanks
    ? leaderboard.indexWhere(
          (item) => item['name'] == 'You',
        ) +
        1
    : 0;
    double calculatedWinningPrize = 0.0;

if (calculatedLiveRank > 0) {
  final rawSlabs = widget.contest?['prizeSlabs'];

  if (rawSlabs is List && rawSlabs.isNotEmpty) {
    for (final slab in rawSlabs) {
      if (slab is Map) {
        final from = int.tryParse('${slab['from']}');
        final to = int.tryParse('${slab['to']}');
        final amount =
            double.tryParse('${slab['amount']}') ?? 0.0;

        if (from != null &&
            to != null &&
            calculatedLiveRank >= from &&
            calculatedLiveRank <= to) {
          calculatedWinningPrize = amount;
          break;
        }
      }
    }
  } else if (calculatedLiveRank == 1) {
    calculatedWinningPrize =
        ((widget.contest?['prizePool'] ??
                    widget.match.prizePool)
                as num)
            .toDouble();
  }
}
   

final detailContestName =
    (widget.contest?['contestName'] ?? '')
        .toString()
        .toLowerCase();

final detailWinningType =
    (widget.contest?['winningType'] ?? '')
        .toString()
        .toLowerCase();

final Color contestDetailColor =
    detailWinningType.contains('winner takes all')
        ? const Color(0xFFFFE5E5)
        : detailWinningType.contains('rank wise')
            ? const Color(0xFFE8F5E9)
            : detailContestName.contains('mega')
                ? const Color(0xFFF1E8FF)
                : detailContestName.contains('small')
                    ? const Color(0xFFE7F3FF)
                    : const Color(0xFFFFF0ED);
return Scaffold(
  appBar: AppBar(
  backgroundColor: const Color(0xFF9A5263),
  foregroundColor: Colors.white,
  
    title: Text(
  widget.contest == null
      ? '${widget.match.team1Flag} ${_shortTeamName(widget.match.team1)} vs ${_shortTeamName(widget.match.team2)} ${widget.match.team2Flag} • ${widget.match.matchFormat}'
      : detailTitle.isNotEmpty
          ? detailTitle
          : '${widget.match.team1Flag} ${_shortTeamName(widget.match.team1)} vs ${_shortTeamName(widget.match.team2)} ${widget.match.team2Flag} • ${widget.match.matchFormat}',
),
    ),
  body: ListView(
    padding: const EdgeInsets.all(16),
    children: [
if (showMatchWinner) ...[
  Text(
    matchWinnerText,
    style: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.green,
    ),
    textAlign: TextAlign.center,
  ),
  const SizedBox(height: 4),
  Text(
    '${widget.match.team1} ${widget.match.team1Score ?? 0}/${widget.match.team1Wickets ?? 0}'
    ' • '
    '${widget.match.team2} ${widget.match.team2Score ?? 0}/${widget.match.team2Wickets ?? 0}',
    style: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
    textAlign: TextAlign.center,
  ),
  const SizedBox(height: 12),
],
      // ===== CONTEST DETAILS =====
      // My Matches से खोलने पर यह नहीं दिखेगा
      if (widget.contest != null)
        Card(
  color: contestDetailColor,
  elevation: 1.5,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(18),
    side: const BorderSide(
      color: Color(0xFFD8C9C2),
      width: 1.2,
    ),
  ),
  clipBehavior: Clip.antiAlias,
  child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Contest Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
  'Entry Fee: ₹${((widget.contest?['entryFee'] ?? widget.match.entryFee) as num).toStringAsFixed(0)}',
  style: const TextStyle(
    color: Color(0xFF9A5263),
    fontWeight: FontWeight.bold,
  ),
),

                const SizedBox(height: 6),

                Text(
  'Prize Pool: ₹${((widget.contest?['prizePool'] ?? widget.match.prizePool) as num).toStringAsFixed(0)}',
  style: const TextStyle(
    color: Color(0xFF9A5263),
    fontWeight: FontWeight.bold,
  ),
),

                const SizedBox(height: 6),

                Text(
  'Joined Team: ${widget.contest?['joinedTeamName'] ?? 'Team 1'}',
  style: const TextStyle(
    color: Color(0xFF9A5263),
    fontWeight: FontWeight.bold,
  ),
),

                

                const SizedBox(height: 6),

                 Text(
  calculatedLiveRank <= 0
      ? 'Your Rank: Pending'
      : 'Your Rank: #$calculatedLiveRank',
  style: const TextStyle(
    color: Color(0xFF9A5263),
    fontWeight: FontWeight.bold,
  ),
),
                const SizedBox(height: 6),

Text(
  calculatedLiveRank <= 0
      ? 'Winning Prize: Pending'
      : 'Winning Prize: ₹${calculatedWinningPrize.toStringAsFixed(0)}',
  style: const TextStyle(
    color: Color(0xFF9A5263),
    fontWeight: FontWeight.bold,
  ),
),

                const SizedBox(height: 6),

                Text(
  widget.match.currentStatus == 'UPCOMING'
      ? 'Fantasy Points: 0'
      : 'Fantasy Points: $livePoints',
  style: const TextStyle(
    color: Color(0xFF9A5263),
    fontWeight: FontWeight.bold,
  ),
),
              ],
            ),
          ),
        ),
      if (widget.contest != null)
  InkWell(
    borderRadius: BorderRadius.circular(18),
    onTap: () {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                 Text(
  detailContestName.contains('head')
      ? 'Team Ranks 🏆'
      : 'Top 10 Ranks 🏆',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  winningType.toLowerCase().contains('winner takes all')
                      ? 'Highest points will win • Winner Takes All'
                      : 'Highest points will win',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 18),

               if (!showFinalRanks)
  const Padding(
    padding: EdgeInsets.symmetric(vertical: 30),
    child: Text(
      'Ranks Pending',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF9A5263),
      ),
    ),
  )
else
  Builder(
    builder: (context) {

      // ==========================================
      // ORIGINAL RANK के साथ पूरी leaderboard
      // ==========================================
      final List<Map<String, dynamic>> rankedUsers = [];

      for (int i = 0; i < leaderboard.length; i++) {
        rankedUsers.add({
          'rank': i + 1,
          'user': leaderboard[i],
        });
      }

      // ==========================================
      // YOU को ढूँढना
      // ==========================================
      Map<String, dynamic>? youEntry;

      for (final entry in rankedUsers) {
        final user =
            Map<String, dynamic>.from(entry['user']);

        final name =
            (user['name'] ?? '')
                .toString()
                .trim()
                .toLowerCase();

        if (name == 'you') {
          youEntry = entry;
          break;
        }
      }
          // ==========================================
      // FINAL DISPLAY LIST
      //
      // YOU हमेशा सबसे ऊपर
      // फिर actual Top 10 ranks
      // YOU अगर Top 10 में है तो duplicate नहीं होगा
      // ==========================================
      final List<Map<String, dynamic>> displayUsers = [];

      if (youEntry != null) {
        displayUsers.add(youEntry);
      }

      for (final entry in rankedUsers.take(10)) {

        final user =
            Map<String, dynamic>.from(entry['user']);

        final name =
            (user['name'] ?? '')
                .toString()
                .trim()
                .toLowerCase();

        // YOU पहले ही ऊपर add हो चुका है
        if (name == 'you') {
          continue;
        }

        displayUsers.add(entry);
      }

      return Column(
        children: displayUsers.map((entry) {

          final int rank =
              entry['rank'] as int;

          final Map<String, dynamic> user =
              Map<String, dynamic>.from(
                entry['user'],
              );

          final String name =
    (user['name'] ?? 'User')
        .toString();

final bool isYou =
    name.trim().toLowerCase() == 'you';

final String rankBadge =
    rank == 1
        ? '🥇 👑'
        : rank == 2
            ? '🥈'
            : rank == 3
                ? '🥉'
                : '';

final String displayName =
    rankBadge.isNotEmpty
        ? '${isYou ? 'You' : name} $rankBadge'
        : (isYou ? 'You' : name);

          final double points =
              ((user['points'] ?? 0) as num)
                  .toDouble();

          final double winning =
              _contestWinningForRank(rank);      
                // ======================================
          // RANK COLOR SYSTEM
          // ======================================

          Color rowColor;
          Color borderColor;
          Color rankColor;

          // 🥇 Rank 1
          if (rank == 1) {
            rowColor =
                const Color(0xFFFFF3C4);

            borderColor =
                const Color(0xFFD4A017);

            rankColor =
                const Color(0xFFB8860B);
          }

          // 🥈 Rank 2
          else if (rank == 2) {
            rowColor =
                const Color(0xFFF1F3F5);

            borderColor =
                const Color(0xFFB0BEC5);

            rankColor =
                const Color(0xFF78909C);
          }

          // 🥉 Rank 3
          else if (rank == 3) {
            rowColor =
                const Color(0xFFFFE8D6);

            borderColor =
                const Color(0xFFCD7F32);

            rankColor =
                const Color(0xFFB87333);
          }

          // Rank 4 या उससे नीचे
          else {
            rowColor =
                const Color(0xFFFFF4F6);

            borderColor =
                const Color(0xFFF0C8D1);

            rankColor =
                const Color(0xFF333333);
          }

          return Container(
            margin:
                const EdgeInsets.only(
              bottom: 8,
            ),

            padding:
                const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),

            decoration: BoxDecoration(
              color: rowColor,

              borderRadius:
                  BorderRadius.circular(14),

              border: Border.all(
                color: borderColor,
                width: 1.2,
              ),
            ),

            child: Row(
              children: [

                // =========================
                // RANK
                // =========================
                SizedBox(
                  width: 55,
                  child: Text(
                    '#$rank',
                    style: TextStyle(
                      fontWeight:
                          FontWeight.bold,
                      color: rankColor,
                    ),
                  ),
                ),
                
                // =========================
                // USER NAME
                // =========================
                Expanded(
  child: Text(
    displayName,
                    style: const TextStyle(
                      fontWeight:
                          FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),

                // =========================
                // POINTS
                // =========================
                SizedBox(
                  width: 65,
                  child: Text(
                    points % 1 == 0
                        ? points
                            .toStringAsFixed(0)
                        : points
                            .toStringAsFixed(1),

                    textAlign:
                        TextAlign.center,

                    style:
                        const TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),

                // =========================
                // WINNING
                // =========================
                SizedBox(
                  width: 70,
                  child: Text(
                    '₹${winning.toStringAsFixed(0)}',

                    textAlign:
                        TextAlign.right,

                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    },
  ),
                
                
              ],
            ),
          );
        },
      );
    },
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE8EE),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFD88B9C),
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events,
            color: Color(0xFF9A5263),
          ),
          Text(
  detailContestName.contains('head')
      ? 'Team Ranks 🏆'
      : 'Top 10 Ranks 🏆',
  style: const TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.bold,
    color: Color(0xFF9A5263),
  ),
),
        ],
      ),
    ),
  ),

      const SizedBox(height: 12),

      // ===== MATCH SCORE / DETAILS =====
      Card(
  color: widget.contest != null
      ? contestDetailColor
      : null,
  elevation: 1.5,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(18),
    side: const BorderSide(
      color: Color(0xFFD8C9C2),
      width: 1.2,
    ),
  ),
  clipBehavior: Clip.antiAlias,
  child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Text(
  widget.match.currentStatus == 'UPCOMING'
      ? '${widget.match.team1Flag} '
    '${_shortTeamName(widget.match.team1)} vs ${_shortTeamName(widget.match.team2)} '
    '${widget.match.team2Flag}\n'
          'Match Not Started'
      : '${widget.match.team1Flag} '
          '${_shortTeamName(widget.match.team1)} '
          '$team1LiveScore/$team1LiveWickets '
          'vs '
          '$team2LiveScore/$team2LiveWickets '
          '${_shortTeamName(widget.match.team2)} '
          '${widget.match.team2Flag}',
  textAlign: TextAlign.center,
  style: const TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
  ),
),

              const SizedBox(height: 10),

              Text(
                widget.contest != null
                    ? 'Contest Joined ✓'
                    : 'Match Joined ✓',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
      
      const SizedBox(height: 12),
            // ===== POINTS सिर्फ CONTEST में =====
      if (widget.contest != null)
  Card(
    color: contestDetailColor,
    elevation: 1.5,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
      side: const BorderSide(
        color: Color(0xFFD8C9C2),
        width: 1.2,
      ),
    ),
    clipBehavior: Clip.antiAlias,
    child: ListTile(
            title: const Text('Total Points'),
            trailing: Text(
              widget.match.currentStatus == 'UPCOMING'
                  ? '0'
                  : '$livePoints',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

      if (widget.contest != null)
        const SizedBox(height: 12),

      // ===== WON / LOST सिर्फ CONTEST में =====
if (widget.contest != null &&
    contestCompleted)
  Card(
    color: contestDetailColor,
    elevation: 1.5,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
      side: const BorderSide(
        color: Color(0xFFD8C9C2),
        width: 1.2,
      ),
    ),
    clipBehavior: Clip.antiAlias,
    child: ListTile(
      leading: Icon(
        _contestWinningForRank(calculatedLiveRank) > 0
            ? Icons.emoji_events
            : Icons.close,
        color: _contestWinningForRank(calculatedLiveRank) > 0
            ? Colors.green
            : Colors.red,
      ),
      title: Text(
        _contestWinningForRank(calculatedLiveRank) > 0
            ? 'WON'
            : 'LOST',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: _contestWinningForRank(calculatedLiveRank) > 0
              ? Colors.green
              : Colors.red,
        ),
      ),
      trailing: Text(
        'Rank #$calculatedLiveRank',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    ),
  ),

      if (widget.contest != null && contestCompleted)
        const SizedBox(height: 12),

      // ===== FINAL MATCH RESULT =====
      if (contestCompleted)
  Card(
    color: widget.contest != null
        ? contestDetailColor
        : null,
    elevation: 1.5,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
      side: const BorderSide(
        color: Color(0xFFD8C9C2),
        width: 1.2,
      ),
    ),
    clipBehavior: Clip.antiAlias,
    child: ListTile(
  title: const Text(
    'Final Result',
    style: TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.bold,
    ),
  ),

  subtitle: Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Text(
      '${widget.match.team1Flag} '
      '${_shortTeamName(widget.match.team1)} '
      '$team1LiveScore/$team1LiveWickets'
      '  -  '
      '$team2LiveScore/$team2LiveWickets '
      '${_shortTeamName(widget.match.team2)} '
      '${widget.match.team2Flag}',
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),

  trailing: Text(
    team1LiveScore > team2LiveScore
        ? '👑\n${widget.match.team1} WON'
        : team2LiveScore > team1LiveScore
            ? '👑\n${widget.match.team2} WON'
            : 'TIE',
    textAlign: TextAlign.center,
    style: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: Colors.green,
    ),
  ),
),
    ),

      if (widget.contest != null)
  const SizedBox(height: 20),

if (widget.contest != null)
  ValueListenableBuilder<Set<String>>(
    valueListenable: claimedWinnings,
    builder: (context, claimed, _) {
      final contestName =
          (widget.contest?['contestName'] ??
                  widget.match.contestName)
              .toString();

     final contest = widget.contest!;

final String teamKey =
    (contest['teamName'] ??
            contest['selectedTeam'] ??
            contest['teamIndex'] ??
            contest['teamId'] ??
            '')
        .toString();

final String contestId =
    (contest['contestId'] ?? contest['id'] ?? '')
        .toString()
        .trim();

final String matchKey =
    (contest['matchKey'] ??
            '${widget.match.team1}-${widget.match.team2}')
        .toString();

final String claimKey = contestId.isNotEmpty
    ? '$matchKey-$contestId-$teamKey'
    : '$matchKey-$contestName-$teamKey';

      final alreadyClaimed =
    claimed.contains(claimKey) ||
    transactionHistory.value.any((tx) {
      if (tx['title'] != 'Winning') return false;

      final savedContestId =
          (tx['contestId'] ?? '').toString().trim();

      final savedTeamKey =
          (tx['teamKey'] ?? '').toString().trim();

      return savedContestId == contestId &&
          savedTeamKey == teamKey;
    });

      
            final winningForThisRank =
    _contestWinningForRank(calculatedLiveRank);

return ElevatedButton(
  onPressed: null,
  style: ElevatedButton.styleFrom(
    elevation: 0,
    disabledBackgroundColor: !contestCompleted
        ? const Color(0xFFFFB74D) // Result Pending
        : winningForThisRank <= 0
            ? const Color(0xFFEF5350) // No Winning
            : alreadyClaimed
                ? const Color(0xFF43A047) // Winning Credited
                : const Color(0xFFFFB300), // Claim Winning
    disabledForegroundColor: Colors.white,
    minimumSize: const Size(double.infinity, 52),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
    ),
  ),
  child: Text(
    !contestCompleted
        ? 'RESULT PENDING'
        : winningForThisRank <= 0
            ? 'NO WINNING'
            : alreadyClaimed
                ? 'WINNING CREDITED ✓\n'
                    '₹${winningForThisRank % 1 == 0 ? winningForThisRank.toInt() : winningForThisRank} ADDED TO WALLET ✓'
                : 'CLAIM WINNING',
    textAlign: TextAlign.center,
  ),
);
    },
  ),

      const SizedBox(height: 20),
    ],
  ),
);
    }
}
// ================= PROFILE =================
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String playerName = '';
  String username = '';
  String mobileNumber = '';
  IconData profileIcon = Icons.person;

  @override
  void initState() {
    super.initState();
    _loadLoggedInProfile();
  }

  Future<void> _loadLoggedInProfile() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final data = doc.data();

      if (!mounted) return;

      final savedUsername =
          (data?['username'] ?? '').toString().trim();

      final savedMobile =
          (data?['mobile'] ?? '').toString().trim();

      final savedName =
          (data?['playerName'] ??
                  data?['name'] ??
                  '')
              .toString()
              .trim();

      setState(() {
        username = savedUsername.isNotEmpty
            ? '@${savedUsername.replaceFirst('@', '')}'
            : (user.email ?? 'User');

        mobileNumber = savedMobile;

        playerName = savedName.isNotEmpty
            ? savedName
            : savedUsername;
      });
    } catch (e) {
      debugPrint('Profile load error: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          
          Card(
  margin: EdgeInsets.zero,
  color: const Color(0xFFFFF1F4),
  surfaceTintColor: Colors.transparent,
  elevation: 1,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(18),
    side: BorderSide(
      color: Colors.pink.shade100,
      width: 1,
    ),
  ),
  child: Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 14,
    ),
    child: Row(
      children: [
        GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                final icons = <IconData>[
                  Icons.person,
                  Icons.sports_cricket,
                  Icons.emoji_events,
                  Icons.star,
                ];

                return AlertDialog(
                  title: const Text('Choose Profile Icon'),
                  content: Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: icons.map((icon) {
                      return IconButton(
                        iconSize: 40,
                        onPressed: () {
                          setState(() {
                            profileIcon = icon;
                          });
                          Navigator.pop(context);
                        },
                        icon: Icon(icon),
                      );
                    }).toList(),
                  ),
                );
              },
            );
          },
          child: CircleAvatar(
            radius: 38,
            backgroundColor: Colors.pink.shade50,
            child: Icon(
              profileIcon,
              size: 45,
              color: Colors.pink.shade700,
            ),
          ),
        ),

        const SizedBox(width: 16),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                username,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                mobileNumber,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        OutlinedButton.icon(
          
                    style: OutlinedButton.styleFrom(
  backgroundColor: const Color(0xFFFFE7F0),
  foregroundColor: const Color(0xFFC2185B),
  side: const BorderSide(
    color: Color(0xFFE91E63),
    width: 1.2,
  ),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(24),
  ),
),
          onPressed: () {
            final controller =
                TextEditingController(text: playerName);

            final usernameController =
                TextEditingController(text: username);

            final mobileController =
                TextEditingController(text: mobileNumber);

            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Edit Profile'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: controller,
                        decoration: const InputDecoration(
                          labelText: 'Player Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                     controller: usernameController,
                     readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                    controller: mobileController,
                    readOnly: true,
                      
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Mobile Number',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('CANCEL'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
  final newName = controller.text.trim();
  final user = FirebaseAuth.instance.currentUser;

  if (user == null || newName.isEmpty) {
    return;
  }

  await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .set(
    {
      'playerName': newName,
    },
    SetOptions(merge: true),
  );

  if (!mounted) return;

  setState(() {
    playerName = newName;
  });

  Navigator.pop(context);
},
                      child: const Text('SAVE'),
                    ),
                  ],
                );
              },
            );
          },
          icon: const Icon(Icons.edit),
          label: const Text('Edit Profile'),
        ),
      ],
    ),
  ),
),

const SizedBox(height: 12),  

FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
  future: FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser?.uid)
      .get(),
  builder: (context, snapshot) {
    final data = snapshot.data?.data();

    final bool isAdmin =
        (data?['role'] ?? '')
                .toString()
                .trim()
                .toUpperCase() ==
            'ADMIN';

    if (!isAdmin) {
      return const SizedBox.shrink();
    }

    return Card(
      child: ListTile(
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: const Color(0xFFFFE9DD),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.admin_panel_settings,
            color: Colors.deepOrange,
            size: 28,
          ),
        ),
        title: const Text('Admin Dashboard'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const AdminDashboardPage(),
            ),
          );
        },
      ),
    );
  },
),

          
const SizedBox(height: 15),

Row(
  children: [
    // ===== TOTAL WINNINGS =====
    Expanded(
      child: Card(
        child: Container(
          height: 110,
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4D6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.workspace_premium,
                  color: Colors.amber,
                  size: 28,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Winnings',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 5),

                    ValueListenableBuilder<
                        List<Map<String, dynamic>>>(
                      valueListenable: transactionHistory,
                      builder: (context, history, _) {
                        double totalWinnings = 0;

                        for (final item in history) {
                          if (item['title'] == 'Winning') {
                            totalWinnings +=
                                (item['amount'] as num?)
                                        ?.toDouble() ??
                                    0;
                          }
                        }

                        return Text(
                          '₹${totalWinnings.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),

    const SizedBox(width: 10),
// ===== WALLET =====
    Expanded(
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const WalletPage(),
              ),
            );
          },
          child: Container(
            height: 110,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet,
                    color: Colors.green,
                    size: 28,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Wallet',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 5),

                      ValueListenableBuilder<double>(
                        valueListenable: walletBalance,
                        builder: (context, balance, _) {
                          return Text(
                            '₹${balance.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const Icon(
                  Icons.chevron_right,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  ],
),

const SizedBox(height: 12),

Card(
  child: ListTile(
    leading: Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2F1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.receipt_long,
        color: Colors.teal,
        size: 28,
      ),
    ),
    title: const Text('Transaction History'),
    trailing: const Icon(Icons.chevron_right),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const TransactionHistoryPage(),
        ),
      );
    },
  ),
),

Card(
  child: ListTile(
    leading: Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: const Color(0xFFECEFF1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.settings,
        color: Colors.blueGrey,
        size: 28,
      ),
    ),
    title: const Text('Settings'),
    trailing: const Icon(Icons.chevron_right),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const SettingsPage(),
        ),
      );
    },
  ),
),

Card(
  child: ListTile(
    leading: Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: const Color(0xFFF3E8FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.card_giftcard,
        color: Colors.deepPurple,
        size: 28,
      ),
    ),
    title: const Text('Refer & Earn'),
    subtitle: const Text(
      'Invite friends & earn rewards',
    ),
    trailing: const Icon(Icons.chevron_right),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const ReferEarnPage(),
        ),
      );
    },
  ),
),

Card(
  child: ListTile(
    leading: Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.help_outline,
        color: Colors.orange,
        size: 28,
      ),
    ),
    title: const Text('Help & Support'),
    trailing: const Icon(Icons.chevron_right),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const HelpSupportPage(),
        ),
      );
    },
  ),
),
 
          Card(
  child: ListTile(
    leading: Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.logout,
        color: Colors.red,
        size: 28,
      ),
    ),
    title: const Text('Logout'),
    trailing: const Icon(Icons.chevron_right),
    onTap: () async {
  final bool? shouldLogout = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        title: const Row(
          children: [
            CircleAvatar(
              backgroundColor: Color(0xFFFFE5E5),
              child: Icon(
                Icons.logout,
                color: Colors.red,
              ),
            ),
            SizedBox(width: 12),
            Text(
              'Logout?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: const Text(
          'क्या आप सच में अपने KhelBaaz account से logout करना चाहते हैं?',
          style: TextStyle(
            fontSize: 15,
            height: 1.4,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(
          16,
          0,
          16,
          16,
        ),
        actions: [
          OutlinedButton(
            onPressed: () {
              Navigator.pop(dialogContext, false);
            },
            child: const Text('नहीं'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(dialogContext, true);
            },
            icon: const Icon(Icons.logout),
            label: const Text('हाँ, Logout'),
          ),
        ],
      );
    },
  );

  if (shouldLogout == true) {
    await FirebaseAuth.instance.signOut();
  }
},
     ),
),
],
),
);
}
}     


class MyTeamsPage extends StatelessWidget {
  const MyTeamsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Teams')),
      body: ValueListenableBuilder<List<List<Player>>>(
        valueListenable: savedTeams,
        builder: (context, teams, _) {
          if (teams.isEmpty) {
            return const Center(
              child: Text(
                'अभी कोई saved team नहीं है',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final matchGroups = <String, List<int>>{};

for (int i = 0; i < teams.length; i++) {
  if (i >= savedTeamMatchKeys.length) continue;

  final key = savedTeamMatchKeys[i];

  matchGroups.putIfAbsent(key, () => []);
  matchGroups[key]!.add(i);
}


bool keepTeamMatch(String matchKey) {
  MatchModel? linkedMatch;

  for (final m in joinedMatches.value) {
    final parts = m.time.split('•');
    final date =
        parts.isNotEmpty ? parts[0].trim() : '';
    final time =
        parts.length > 1 ? parts[1].trim() : '';

    final key =
        '${m.team1}_${m.team2}_${date}_$time';

    if (key == matchKey) {
      linkedMatch = m;
      break;
    }
  }

  if (linkedMatch == null ||
      linkedMatch.currentStatus != 'COMPLETED') {
    return true;
  }

  final completionTime =
      linkedMatch.completedAt ??
      linkedMatch.startTime?.add(linkedMatch.liveDuration);

  if (completionTime == null) {
    return true;
  }

  final deleteAt =
    completionTime.add(const Duration(days: 6));

return DateTime.now().isBefore(deleteAt);
}
          final matchKeys =
    matchGroups.keys.where(keepTeamMatch).toList();
return ListView.builder(
  padding: const EdgeInsets.all(12),
  itemCount: matchKeys.length,
  itemBuilder: (context, matchIndex) {
    final matchKey = matchKeys[matchIndex];
    final teamIndexes = matchGroups[matchKey]!;

    String matchName = matchKey;
String matchDate = '';
String matchTime = '';
final keyParts = matchKey.split('_');
if (keyParts.length >= 2) {
  matchName = '${keyParts[0]} vs ${keyParts[1]}';
}

    for (final m in joinedMatches.value) {
      final parts = m.time.split('•');
      final date = parts.isNotEmpty ? parts[0].trim() : '';
      final time = parts.length > 1 ? parts[1].trim() : '';

      final key =
          '${m.team1}_${m.team2}_${date}_$time';

      if (key == matchKey) {
        matchName = '${m.team1} vs ${m.team2}';
        matchDate = date;
matchTime = time;
        break;
      }
    }
String matchFormat = '';

for (final m in adminMatches.value) {
  final adminName =
      '${m['team1'] ?? ''} vs ${m['team2'] ?? ''}'
          .trim()
          .toLowerCase();

  if (adminName == matchName.trim().toLowerCase()) {
    matchFormat = (m['matchFormat'] ?? '').toString();
    break;
  }
}
    final now = DateTime.now();

String dateTimeLabel = '';

if (matchDate.isNotEmpty) {
  try {
    final p = matchDate.split('/');
    final d = DateTime(
      int.parse(p[2]),
      int.parse(p[1]),
      int.parse(p[0]),
    );

    final isToday =
        d.year == now.year &&
        d.month == now.month &&
        d.day == now.day;

    dateTimeLabel = isToday
        ? 'TODAY${matchTime.isNotEmpty ? ' • $matchTime' : ''}'
        : '$matchDate${matchTime.isNotEmpty ? ' • $matchTime' : ''}';
  } catch (_) {
    dateTimeLabel =
        '$matchDate${matchTime.isNotEmpty ? ' • $matchTime' : ''}';
  }
}
    final dateHeader = Container(
  padding: const EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 7,
  ),
  decoration: BoxDecoration(
    color: const Color(0xFFFFE1E1),
    borderRadius: BorderRadius.circular(10),
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Icon(
        Icons.calendar_month,
        size: 18,
        color: Color(0xFFD94B4B),
      ),
      const SizedBox(width: 6),
      Text(
        dateTimeLabel,
        style: const TextStyle(
          color: Color(0xFFB53A3A),
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  ),
);
    final nameParts = matchName.split(' vs ');

final team1Name =
    nameParts.isNotEmpty ? nameParts[0].trim() : '';

final team2Name =
    nameParts.length > 1 ? nameParts[1].trim() : '';
final adminMatch = adminMatches.value.where(
  (m) =>
      m['team1'] == team1Name &&
      m['team2'] == team2Name,
).toList();

final team1Flag = adminMatch.isNotEmpty
    ? (adminMatch.first['team1Logo'] ?? '').toString()
    : '';

final team2Flag = adminMatch.isNotEmpty
    ? (adminMatch.first['team2Logo'] ?? '').toString()
    : '';
String shortName(String name) {
  final words = name
      .split(' ')
      .where((e) => e.isNotEmpty)
      .toList();

  if (words.length == 1) {
    return name.length <= 3
        ? name.toUpperCase()
        : name.substring(0, 3).toUpperCase();
  }

  return words.map((e) => e[0]).join().toUpperCase();
}

final team1Short = shortName(team1Name);
final team2Short = shortName(team2Name);
    return Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    dateHeader,
    const SizedBox(height: 6),
    Card(
      color: const Color(0xFFD9E8FF),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.sports_cricket),
        ),
        title: Row(
  children: [
    CircleAvatar(
  radius: 15,
  backgroundColor: const Color(0xFFFFFFFF),
  child: Text(
    team1Flag,
    style: const TextStyle(fontSize: 20),
  ),
),
    const SizedBox(width: 7),

    Text(
      team1Short,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ),

    const Padding(
      padding: EdgeInsets.symmetric(horizontal: 7),
      child: Text(
        'vs',
        style: TextStyle(
          color: Color(0xFF4F5560),
          fontWeight: FontWeight.bold,
        ),
      ),
    ),

    Text(
      team2Short,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ),

    const SizedBox(width: 7),
    CircleAvatar(
      radius: 15,
      backgroundColor: Color(0xFFFFFFFF),
      child: Text(
  team2Flag,
  style: const TextStyle(fontSize: 20),
),
    ),
  
          const SizedBox(width: 7),

Container(
  padding: const EdgeInsets.symmetric(
    horizontal: 8,
    vertical: 4,
  ),
  decoration: BoxDecoration(
    color: const Color(0xFFD4D9F2),
    borderRadius: BorderRadius.circular(10),
  ),
  child: Text(
    matchFormat,
    style: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      color: Color(0xFF3949AB),
    ),
  ),
),
    ],
),
        subtitle: Text(
  '${teamIndexes.length} Teams  •  $dateTimeLabel',
),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MatchTeamsPage(
                matchName: matchName,
                teamIndexes: teamIndexes,
              ),
            ),
          );
        },
      ),
    ),
    ],
);
          },
      );
    },
  ),
);
}
}
class MatchTeamsPage extends StatelessWidget {
  final String matchName;
  final List<int> teamIndexes;

  const MatchTeamsPage({
    super.key,
    required this.matchName,
    required this.teamIndexes,
  });

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? currentMatch;

for (final m in adminMatches.value) {
  final adminName =
      '${m['team1'] ?? ''} vs ${m['team2'] ?? ''}'
          .trim()
          .toLowerCase();

  if (adminName == matchName.trim().toLowerCase()) {
    currentMatch = m;
    break;
  }
}
    final team1Name = (currentMatch?['team1'] ?? '').toString();
final team2Name = (currentMatch?['team2'] ?? '').toString();
final matchFormat = (currentMatch?['matchFormat'] ?? '').toString();
final team1Flag =
    (currentMatch?['team1Logo'] ?? '').toString();
final team2Flag =
    (currentMatch?['team2Logo'] ?? '').toString();
String makeShortName(String name) {
  final words = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((e) => e.isNotEmpty)
      .toList();

  if (words.isEmpty) return '';

  if (words.length == 1) {
    final word = words.first.toUpperCase();

    return word.length <= 3
        ? word
        : word.substring(0, 3);
  }

  return words
      .take(3)
      .map((e) => e[0].toUpperCase())
      .join();
}

final team1Short = makeShortName(team1Name);
final team2Short = makeShortName(team2Name);
    return Scaffold(
      appBar: AppBar(
  title: Text(
  '$team1Flag $team1Short vs $team2Short $team2Flag'
  '${matchFormat.isNotEmpty ? ' • $matchFormat' : ''}',
),
),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: teamIndexes.length,
        itemBuilder: (context, index) {
          final globalIndex = teamIndexes[index];
          final team = savedTeams.value[globalIndex];

          return Card(
            color: const Color(0xFFD7E6DA),
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const CircleAvatar(
  backgroundColor: Color(0xFFFFD6D6),
  child: Icon(
    Icons.groups,
    color: Color(0xFF8B3A3A),
  ),
),
              title: Text(
  'Team ${index + 1}',
  style: const TextStyle(
    fontWeight: FontWeight.bold,
    color: Color(0xFF2F3A4A),
  ),
),
              subtitle: Text(
  '${team.length} Players',
  style: const TextStyle(
    color: Color(0xFF5A6470),
    fontWeight: FontWeight.w600,
  ),
),
              trailing: const Icon(
  Icons.chevron_right,
  color: Color(0xFF4A4F57),
),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SavedTeamDetailPage(
                      team: team,
                      teamNumber: index + 1,
                      captainName:
                          savedCaptainNames[globalIndex],
                      viceCaptainName:
                          savedViceCaptainNames[globalIndex],
                      matchKey:
                          savedTeamMatchKeys[globalIndex],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class SavedTeamDetailPage extends StatelessWidget {
  final List<Player> team;
  final int teamNumber;
final String captainName;
final String viceCaptainName;
  final String matchKey;
  const SavedTeamDetailPage({
  super.key,
  required this.team,
  required this.teamNumber,
  required this.captainName,
  required this.viceCaptainName,
    required this.matchKey,
});

  @override
  Widget build(BuildContext context) {
    double totalTeamPoints = 0.0;

final matchStats = savedPlayerStats[matchKey] ?? {};

for (final player in team) {
  double points = player.points;

  final matchingStats = matchStats.entries
      .where(
        (entry) =>
            entry.key.split('|').first.trim() ==
            player.name.trim(),
      )
      .map((entry) => entry.value)
      .toList();

  if (matchingStats.isNotEmpty) {
    final stats = matchingStats.last;

    final runs = stats['runs'] ?? 0;
final fours = stats['fours'] ?? 0;
final sixes = stats['sixes'] ?? 0;
final wickets = stats['wickets'] ?? 0;
final catches = stats['catches'] ?? 0;

points =
    runs +
    (fours * 2) +
    (sixes * 4) +
    (wickets * 30) +
    (catches * 10);
}
if (player.name == captainName) {
  points *= 2;
} else if (player.name == viceCaptainName) {
  points *= 1.5;
}

totalTeamPoints += points;
}
    return Scaffold(
      appBar: AppBar(
        title: Text('Team $teamNumber'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: team.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
  return Card(
    color: const Color(0xFF4527A0),
    margin: const EdgeInsets.only(bottom: 14),
    child: ListTile(
      leading: const CircleAvatar(
        backgroundColor: Color(0xFFFFD54F),
        child: Icon(
          Icons.star,
          color: Color(0xFF4527A0),
        ),
      ),
      title: const Text(
        'TOTAL POINTS',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      trailing: Text(
        totalTeamPoints.toStringAsFixed(1),
        style: const TextStyle(
          color: Color(0xFFFFE082),
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}

final player = team[index - 1];
         
final matchStats = savedPlayerStats[matchKey] ?? {};

final matchingStats = matchStats.entries
    .where((entry) =>
        entry.key.split('|').first.trim() ==
        player.name.trim())
    .map((entry) => entry.value)
    .toList();
if (matchingStats.isNotEmpty) {
  final stats = matchingStats.last;


  player.runs = stats['runs'] ?? 0;
  player.fours = stats['fours'] ?? 0;
  player.sixes = stats['sixes'] ?? 0;
  player.wickets = stats['wickets'] ?? 0;
  player.catches = stats['catches'] ?? 0;
}
          double displayPoints = player.points;

if (player.name == captainName) {
  displayPoints = player.points * 2;
} else if (player.name == viceCaptainName) {
  displayPoints = player.points * 1.5;
}
          
            return Card(
  color: player.name == captainName
      ? const Color(0xFFE8F5E9)
      : player.name == viceCaptainName
          ? const Color(0xFFE3F2FD)
          : const Color(0xFFFFF1F1),
  child: ListTile(
              leading: CircleAvatar(
                child: Text(player.name[0]),
              ),
              title: Row(
  children: [
    Text(
      player.name,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ),

    if (player.name == captainName) ...[
      const SizedBox(width: 8),
      Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 2,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF00A51A),
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Text(
          'C',
          style: TextStyle(
            color: Color(0xFFFFFFFF),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      const SizedBox(width: 6),
      const Text('👑'),
    ],

    if (player.name == viceCaptainName) ...[
      const SizedBox(width: 8),
      Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 2,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF1565D8),
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Text(
          'VC',
          style: TextStyle(
            color: Color(0xFFFFFFFF),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ],
  ],
),
              subtitle: Text(
  '${player.team} • ${player.role}\n'
  'Runs: ${player.runs}   4s: ${player.fours}   6s: ${player.sixes}\n'
  'Wkts: ${player.wickets}   Catch: ${player.catches}',
),
isThreeLine: true,
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${player.credit}'),
                 Container(
  padding: const EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 5,
  ),
  decoration: BoxDecoration(
    color: player.name == captainName
        ? const Color(0xFF81C784)
        : player.name == viceCaptainName
            ? const Color(0xFF90CAF9)
            : const Color(0xFFD1B3FF),
    borderRadius: BorderRadius.circular(15),
  ),
  child: Text(
    'Points: ${displayPoints.toStringAsFixed(1)}',
    style: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
    ),
  ),
),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
  child: Column(
          children: [
            ValueListenableBuilder<double>(
  valueListenable: walletBalance,
  builder: (context, balance, _) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 9,
        ),
        decoration: BoxDecoration(
          color: Colors.green.shade700,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.account_balance_wallet,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 6),
            Text(
              '₹${balance.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  },
),

            const SizedBox(height: 25),
ElevatedButton.icon(
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.amber,
    foregroundColor: Colors.black,
  ),
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const WalletRequestsPage(),
      ),
    );
  },
  icon: const Icon(Icons.receipt_long),
  label: const Text(
    'MY REQUESTS',
    style: TextStyle(fontWeight: FontWeight.bold),
  ),
),

const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                   style: ElevatedButton.styleFrom(
  backgroundColor: Colors.blue,
  foregroundColor: Colors.white,
),
                    onPressed: () {
                      showDepositRequestDialog(context);
                    },
                    child: const Text('DEPOSIT REQUEST'),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
  backgroundColor: Colors.red,
  foregroundColor: Colors.white,
),
                    onPressed: () {
                      showWithdrawRequestDialog(context);
                    },
                    child: const Text('WITHDRAW REQUEST'),
                  ),
                ),
              ],
            ),
            
          const SizedBox(height: 24),

const Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Text(
      'Recent Transactions',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
    Text(
      'Last 5 Recent ⬇️⬆️',
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    ),
  ],
),

const SizedBox(height: 10),

ValueListenableBuilder<List<Map<String, dynamic>>>(
  valueListenable: transactionHistory,
  builder: (context, history, _) { 
    DateTime? txDate(Map<String, dynamic> tx) {
      final raw =
    tx['dateTime'] ??
    tx['timestamp'] ??
    tx['createdAt'] ??
    tx['date'];

      if (raw is DateTime) return raw;
      if (raw == null) return null;

      final text = raw.toString();
      final normal = DateTime.tryParse(text);

      if (normal != null) return normal;

      final p = text.split(' ');
      final d = p[0].split('/');

      if (d.length != 3) return null;

      final t = p.length > 1
    ? p[1].split(':')
    : <String>[];

final hour =
    t.isNotEmpty ? int.tryParse(t[0]) ?? 0 : 0;

final minute =
    t.length > 1 ? int.tryParse(t[1]) ?? 0 : 0;

return DateTime(
  int.parse(d[2]),
  int.parse(d[1]),
  int.parse(d[0]),
  hour,
  minute,
);
    }

    final now = DateTime.now();

    final recent = history.where((tx) {
      final title =
          (tx['title'] ?? '').toString().toLowerCase();

      if (!title.contains('deposit') &&
          !title.contains('withdraw')) {
        return false;
      }

      final d = txDate(tx);
      if (d == null) return true;

      return now.difference(d).inDays <= 10;
    }).toList().reversed.take(5).toList();
        if (recent.isEmpty) {
      return const Text(
        'No recent deposit/withdraw transactions',
      );
    }

    return Column(
      children: recent.map((tx) {
        final title =
            (tx['title'] ?? 'Transaction').toString();

        final lowerTitle = title.toLowerCase();

final withdraw =
    lowerTitle.contains('withdraw');

final reversed =
    lowerTitle.contains('deposit reversed');

final isMinus = withdraw || reversed;

        final amount = double.tryParse(
              (tx['amount'] ?? 0).toString(),
            ) ??
            0;

        final d = txDate(tx);

String realTime = '';

for (final value in tx.values) {
  final match = RegExp(
    r'\b([01]?\d|2[0-3]):[0-5]\d\b',
  ).firstMatch(value.toString());

  if (match != null &&
      match.group(0) != '00:00') {
    realTime = match.group(0)!;
    break;
  }
}

final date = d == null
    ? ''
    : '${d.day}/${d.month}/${d.year}'
      '${realTime.isNotEmpty ? '  $realTime' : ''}';

        return Card(
  color: reversed
      ? Colors.red.shade50
      : withdraw
          ? Colors.blue.shade50
          : Colors.green.shade50,
  child: ListTile(
    leading: Transform(
      alignment: Alignment.center,
      transform: Matrix4.rotationY(
        reversed || withdraw ? 0 : 3.14159,
      ),
      child: Icon(
        reversed
            ? Icons.undo
            : Icons.keyboard_return,
        size: 32,
        color: reversed
            ? Colors.red
            : withdraw
                ? Colors.blue
                : Colors.green.shade700,
      ),
    ),
    title: Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ),
    subtitle: Text(date),
    trailing: Text(
      '${isMinus ? '-' : '+'}₹${amount.abs().toStringAsFixed(0)}',
      style: TextStyle(
        color: reversed
            ? Colors.red
            : withdraw
                ? Colors.blue
                : Colors.green.shade700,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
);
      }).toList(),
    );
  },
),
],
),
),
),
);
}
}
class WalletRequestsPage extends StatelessWidget {
  const WalletRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Requests'),
      ),
      body: ValueListenableBuilder<List<Map<String, dynamic>>>(
        valueListenable: walletRequests,
        builder: (context, requests, _) {
          if (requests.isEmpty) {
            return const Center(
              child: Text('No requests yet'),
            );
          }

          final now = DateTime.now();

final list = requests.where((r) {
  final status = (r['status'] ?? 'PENDING').toString();

  if (status == 'PENDING') return true;

  final raw = r['resolvedAt'];

  DateTime? resolvedAt;

  if (raw is DateTime) {
    resolvedAt = raw;
  } else if (raw != null) {
    resolvedAt = DateTime.tryParse(raw.toString());
  }

  if (resolvedAt == null) return true;

  final after24Hours =
      resolvedAt.add(const Duration(hours: 24));

  final nextMidnight = DateTime(
    resolvedAt.year,
    resolvedAt.month,
    resolvedAt.day + 1,
  );

  final deleteAt = after24Hours.isAfter(nextMidnight)
      ? after24Hours
      : nextMidnight;

  return now.isBefore(deleteAt);
}).toList();
list.sort((a, b) {
  DateTime getTime(Map<String, dynamic> r) {
  final status =
      (r['status'] ?? '').toString().toUpperCase();

  final raw = status == 'REVERSED'
      ? (r['reversedAt'] ??
          r['resolvedAt'] ??
          r['createdAt'] ??
          r['dateTime'] ??
          r['date'])
      : (r['resolvedAt'] ??
          r['createdAt'] ??
          r['dateTime'] ??
          r['date']);

  if (raw is DateTime) return raw;

  if (raw != null) {
    final parsed = DateTime.tryParse(raw.toString());
    if (parsed != null) return parsed;
  }

  return DateTime(2000);
}

  return getTime(b).compareTo(getTime(a));
  });
        if (list.length > 5) {
  list.removeRange(5, list.length);
}
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final r = list[index];

              final type =
                  (r['type'] ?? '').toString();

              final status =
                  (r['status'] ?? 'PENDING').toString();

              final amount =
                  double.tryParse(
                    (r['amount'] ?? 0).toString(),
                  ) ??
                  0;
              final adminNote =
    (r['adminNote'] ?? 'Verified payment').toString();
              final rawRequested =
    r['requestedAt'] ?? r['createdAt'];

DateTime? requestedAt;

if (rawRequested is DateTime) {
  requestedAt = rawRequested;
} else if (rawRequested != null) {
  requestedAt =
      DateTime.tryParse(rawRequested.toString());
}

final requestedText = requestedAt == null
    ? ''
    : '${requestedAt.day.toString().padLeft(2, '0')}/'
      '${requestedAt.month.toString().padLeft(2, '0')}/'
      '${requestedAt.year}  '
      '${requestedAt.hour.toString().padLeft(2, '0')}:'
      '${requestedAt.minute.toString().padLeft(2, '0')}';
              
final rawResolved = r['resolvedAt'];

DateTime? resolvedAt;
if (rawResolved is DateTime) {
  resolvedAt = rawResolved;
} else if (rawResolved != null) {
  resolvedAt = DateTime.tryParse(rawResolved.toString());
}

final resolvedText = resolvedAt == null
    ? ''
    : '${resolvedAt.day.toString().padLeft(2, '0')}/'
      '${resolvedAt.month.toString().padLeft(2, '0')}/'
      '${resolvedAt.year} '
      '${resolvedAt.hour.toString().padLeft(2, '0')}:'
      '${resolvedAt.minute.toString().padLeft(2, '0')}';
              final isWithdraw = type == 'WITHDRAW';
final isReversed = status == 'REVERSED';

final color = isReversed
    ? Colors.red
    : isWithdraw
        ? Colors.blue
        : status == 'APPROVED'
            ? Colors.green.shade700
            : status == 'REJECTED'
                ? Colors.red
                : Colors.orange;

final bgColor = isReversed
    ? Colors.red.shade50
    : isWithdraw
        ? Colors.blue.shade50
        : status == 'APPROVED'
            ? Colors.green.shade50
            : status == 'REJECTED'
                ? Colors.red.shade50
                : Colors.orange.shade50;

return Card(
  color: bgColor,
  child: ListTile(
    leading: Transform(
  alignment: Alignment.center,
  transform: Matrix4.rotationY(
    isReversed || isWithdraw ? 0 : 3.14159,
  ),
  child: Icon(
    isReversed
        ? Icons.undo
        : Icons.keyboard_return,
    color: color,
    size: 32,
  ),
),
    title: Text(
      '$type • ₹${amount.toStringAsFixed(0)}',
      style: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ),
    subtitle: Text(
      resolvedText.isEmpty
          ? '$status\n⏰ Request: $requestedText'
          : status == 'APPROVED'
              ? '$status • Admin: $adminNote\n'
                  '⏰ Request: $requestedText\n'
                  '✅ Approved: $resolvedText'
              : isReversed
                  ? 'REVERSED\n'
                      '⏰ Request: $requestedText\n'
                      '↩️ Reversed: $resolvedText'
                  : '$status\n'
                      '⏰ Request: $requestedText\n'
                      '❌ Rejected: $resolvedText',
    ),
    isThreeLine: true,
    trailing: Icon(
      Icons.circle,
      size: 12,
      color: color,
    ),
  ),
);
            },
          );
        },
      ),
    );
  }
}
void showDepositRequestDialog(BuildContext context) {
  final TextEditingController amountController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
  scrollable: true,
  title: const Text('Deposit Request'),
        content: Column(
  mainAxisSize: MainAxisSize.min,
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    TextField(
      controller: amountController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: 'Amount',
        prefixText: '₹ ',
        helperText: 'न्यूनतम ₹50 - अधिकतम ₹10000',
        border: OutlineInputBorder(),
      ),
    ),

    const SizedBox(height: 16),

    const Text(
      'Quick Select',
      style: TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ),

    const SizedBox(height: 10),

    Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        OutlinedButton(
          style: OutlinedButton.styleFrom(
  backgroundColor: Colors.blue.shade50,
  foregroundColor: Colors.blue,
  side: const BorderSide(color: Colors.blue),
),
          onPressed: () {
            amountController.text = '50';
          },
          child: const Text('₹50'),
        ),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
  backgroundColor: Colors.blue.shade50,
  foregroundColor: Colors.blue,
  side: const BorderSide(color: Colors.blue),
),
          onPressed: () {
            amountController.text = '100';
          },
          child: const Text('₹100'),
        ),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
  backgroundColor: Colors.blue.shade50,
  foregroundColor: Colors.blue,
  side: const BorderSide(color: Colors.blue),
),
          onPressed: () {
            amountController.text = '500';
          },
          child: const Text('₹500'),
        ),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
  backgroundColor: Colors.blue.shade50,
  foregroundColor: Colors.blue,
  side: const BorderSide(color: Colors.blue),
),
          onPressed: () {
            amountController.text = '1000';
          },
          child: const Text('₹1000'),
        ),
      ],
    ),
  ],
),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
  backgroundColor: Colors.blue,
  foregroundColor: Colors.white,
),
            onPressed: () {
              
              final double? amount =
                  double.tryParse(amountController.text);

              if (amount == null || amount < 50 || amount > 10000) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        'Deposit amount ₹50 से ₹10000 के बीच होना चाहिए',
      ),
    ),
  );
  return;
}

              Navigator.pop(context);

Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => DepositPaymentPage(
      amount: amount,
    ),
  ),
);
},
            child: const Text('SEND REQUEST'),
          ),
        ],
      );
    },
  );
}

void showWithdrawRequestDialog(BuildContext context) {
  final TextEditingController amountController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
  scrollable: true,
  title: const Text('Withdraw Request'),
        content: Column(
  mainAxisSize: MainAxisSize.min,
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    TextField(
      controller: amountController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: 'Amount',
        prefixText: '₹ ',
      
        helperText: 'न्यूनतम ₹100 - अधिकतम Wallet Balance तक',
        border: OutlineInputBorder(),
      ),
    ),

    const SizedBox(height: 16),

    const Text(
      'Quick Select',
      style: TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ),

    const SizedBox(height: 10),

    Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        
        OutlinedButton(
          style: OutlinedButton.styleFrom(
  backgroundColor: Colors.red,
  foregroundColor: Colors.white,
),
          onPressed: () {
            amountController.text = '100';
          },
          child: const Text('₹100'),
        ),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
  backgroundColor: Colors.red,
  foregroundColor: Colors.white,
),
          onPressed: () {
            amountController.text = '500';
          },
          child: const Text('₹500'),
        ),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
  backgroundColor: Colors.red,
  foregroundColor: Colors.white,
),
          onPressed: () {
            amountController.text = '1000';
          },
          child: const Text('₹1000'),
        ),
      ],
    ),
  ],
),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
  backgroundColor: Colors.red,
  foregroundColor: Colors.white,
),
            onPressed: () {
              final double? amount =
                  double.tryParse(amountController.text);

               if (amount == null || amount < 100) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        'न्यूनतम Withdrawal ₹100 है',
      ),
    ),
  );
  return;
}

              final pendingWithdrawTotal = walletRequests.value
    .where(
      (request) =>
          (request['type'] ?? '')
                  .toString()
                  .toUpperCase() ==
              'WITHDRAW' &&
          (request['status'] ?? '')
                  .toString()
                  .toUpperCase() ==
              'PENDING',
    )
    .fold<double>(0.0, (sum, request) {
  final value = request['amount'];

  if (value is num) {
    return sum + value.toDouble();
  }

  return sum +
      (double.tryParse(value?.toString() ?? '0') ?? 0.0);
});

final double availableBalance =
    (walletBalance.value - pendingWithdrawTotal)
        .clamp(0, double.infinity)
        .toDouble();

if (amount > availableBalance) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        'Insufficient balance • Available ₹${availableBalance.toStringAsFixed(0)}',
      ),
    ),
  );
  return;
}

              addWalletRequest(
                type: 'WITHDRAW',
                amount: amount,
              );

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Withdraw request sent'),
                ),
              );
            },
            child: const Text('SEND REQUEST'),
          ),
        ],
      );
    },
  );
}
class DepositPaymentPage extends StatelessWidget {
  final double amount;

  const DepositPaymentPage({
    super.key,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment QR Code'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Amount: ₹${amount.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          ValueListenableBuilder<String>(
            valueListenable: depositWarningText,
            builder: (context, warning, _) {
              return Card(
                color: Colors.amber.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Text(
                    warning,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 15),

          ValueListenableBuilder<String?>(
  valueListenable: depositPaymentImage,
  builder: (context, image, _) {
    return Container(
      height: 260,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.blueGrey,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Container(
          width: 180,
          height: 180,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: Colors.blue,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: image == null
              ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.qr_code_2,
                      size: 100,
                      color: Colors.black87,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Payment image will appear here',
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    image,
                    fit: BoxFit.contain,
                  ),
                ),
        ),
      ),
    );
  },
),
          const SizedBox(height: 16),

ValueListenableBuilder<String>(
  valueListenable: depositPaymentText,
  builder: (context, paymentText, _) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ElevatedButton.icon(
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.blue,
    foregroundColor: Colors.white,
  ),
  onPressed: () {
                Clipboard.setData(
                  ClipboardData(text: paymentText),
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Payment line copied'),
                  ),
                );
              },
              icon: const Icon(Icons.copy),
              label: const Text('COPY'),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                paymentText,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  },
),
          const SizedBox(height: 12),

OutlinedButton.icon(
  style: OutlinedButton.styleFrom(
    backgroundColor: Colors.teal,
    foregroundColor: Colors.white,
  ),
  onPressed: () {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Payment image save feature ready for later connection',
        ),
      ),
    );
  },
  icon: const Icon(Icons.download),
  label: const Text('SAVE PAYMENT IMAGE'),
),

const SizedBox(height: 12),

ElevatedButton.icon(
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.orange,
    foregroundColor: Colors.white,
  ),
  onPressed: () {
  pickImageFromGallery(
    selectedPaymentScreenshot,
  );
},
  icon: const Icon(Icons.upload),
  label: const Text(
    'UPLOAD PAYMENT SCREENSHOT',
  ),
),
          ValueListenableBuilder<String?>(
  valueListenable: selectedPaymentScreenshot,
  builder: (context, screenshot, _) {
    if (screenshot == null) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 180,
      margin: const EdgeInsets.only(top: 12),
      child: Image.network(
        screenshot,
        fit: BoxFit.contain,
      ),
    );
  },
),
          const SizedBox(height: 12),
Center(
  child: SizedBox(
    width: 280,
    child: ElevatedButton.icon(
  style: ElevatedButton.styleFrom(
  backgroundColor: Colors.orange,
  foregroundColor: Colors.white,
  fixedSize: const Size(280, 50),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(24),
  ),
),
  onPressed: () {
    if (selectedPaymentScreenshot.value == null) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        'पहले payment screenshot upload करें',
      ),
    ),
  );
  return;
}

addWalletRequest(
  type: 'DEPOSIT',
  amount: amount,
  screenshot: selectedPaymentScreenshot.value,
);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '₹${amount.toStringAsFixed(0)} deposit request sent to admin',
        ),
      ),
    );

    Navigator.pop(context);
  },
  icon: const Icon(Icons.check),
  label: const Text('SUBMIT PAYMENT'),
          ),
        ),
      ),
],
      ),
    );
  }
}

class TransactionHistoryPage extends StatelessWidget {
  const TransactionHistoryPage({super.key});
DateTime? _parseHistoryDate(String raw) {
  final text = raw.trim();

  if (text.isEmpty) return null;

  final isoDate = DateTime.tryParse(text);
  if (isoDate != null) return isoDate;

  try {
    final parts = text.split(RegExp(r'\s+'));

    final dateParts = parts[0].split('/');

    if (dateParts.length != 3) {
      return null;
    }

    final timeParts =
        parts.length > 1 ? parts[1].split(':') : <String>[];

    final day = int.parse(dateParts[0]);
    final month = int.parse(dateParts[1]);
    final year = int.parse(dateParts[2]);

    final hour = timeParts.isNotEmpty
        ? int.tryParse(timeParts[0]) ?? 0
        : 0;

    final minute = timeParts.length > 1
        ? int.tryParse(timeParts[1]) ?? 0
        : 0;

    return DateTime(
      year,
      month,
      day,
      hour,
      minute,
    );
  } catch (_) {
    return null;
  }
}

bool _isSameHistoryDay(DateTime a, DateTime b) {
  return a.year == b.year &&
      a.month == b.month &&
      a.day == b.day;
}

String _historyDayTitle(DateTime date) {
  final now = DateTime.now();

  final today =
      DateTime(now.year, now.month, now.day);

  final transactionDay =
      DateTime(date.year, date.month, date.day);

  final difference =
      today.difference(transactionDay).inDays;

  if (difference == 0) {
    return 'TODAY';
  }

  if (difference == 1) {
    return 'YESTERDAY';
  }

  return 'DATE';
}

String _historyFullDate(DateTime date) {
  const months = [
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MAY',
    'JUN',
    'JUL',
    'AUG',
    'SEP',
    'OCT',
    'NOV',
    'DEC',
  ];

  return '${date.day} '
      '${months[date.month - 1]} '
      '${date.year}';
}

Widget _historyDateRibbon(DateTime date) {
  return Container(
    height: 46,
    margin: const EdgeInsets.only(
      top: 3,
      bottom: 6,
    ),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [
          Color(0xFF00796B),
          Color(0xFF26A69A),
          Color(0xFF80CBC4),
        ],
      ),
      borderRadius: BorderRadius.circular(15),
      boxShadow: const [
        BoxShadow(
          color: Color(0x22000000),
          blurRadius: 5,
          offset: Offset(0, 3),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          width: 54,
          height: 46,
          decoration: const BoxDecoration(
            color: Color(0xFF00574B),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              bottomLeft: Radius.circular(15),
            ),
          ),
          child: const Icon(
            Icons.calendar_month_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 14),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _historyDayTitle(date),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _historyFullDate(date),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  toolbarHeight: 68,
  elevation: 0,
  foregroundColor: Colors.white,
  backgroundColor: Colors.transparent,
  flexibleSpace: Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Color(0xFF4527A0),
          Color(0xFF673AB7),
          Color(0xFF7E57C2),
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
    ),
  ),
  titleSpacing: 0,
  title: Row(
    children: [
      Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
  gradient: const LinearGradient(
    colors: [
      Color(0xFFFFD54F),
      Color(0xFFFFB300),
    ],
  ),
  borderRadius: BorderRadius.circular(18),
  border: Border.all(
    color: const Color(0xFFFFF3C4),
    width: 1.5,
  ),
  boxShadow: const [
    BoxShadow(
      color: Color(0x33000000),
      blurRadius: 6,
      offset: Offset(0, 3),
    ),
  ],
),
        child: const Icon(
          Icons.receipt_long_rounded,
          color: Colors.white,
          size: 23,
        ),
      ),
      const SizedBox(width: 10),
      const Text(
        'Transaction History',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  ),
  actions: [
    ValueListenableBuilder<double>(
      valueListenable: walletBalance,
      builder: (context, balance, _) {
        return GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const WalletPage(),
      ),
    );
  },
  child: Container(
          margin: const EdgeInsets.only(
            right: 12,
            top: 11,
            bottom: 11,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 11,
            vertical: 5,
          ),
          decoration: BoxDecoration(
  gradient: const LinearGradient(
    colors: [
      Color(0xFFFFF176),
      Color(0xFFFFC107),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  borderRadius: BorderRadius.circular(16),
  border: Border.all(
    color: const Color(0xFFFFF8E1),
    width: 1.2,
  ),
  boxShadow: const [
    BoxShadow(
      color: Color(0x33000000),
      blurRadius: 5,
      offset: Offset(0, 2),
    ),
  ],
),
          child: Row(
            children: [
              const Icon(
                Icons.account_balance_wallet_rounded,
                color: Color(0xFF4E342E),
                size: 19,
              ),
              const SizedBox(width: 5),
              Text(
                '₹${balance.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Color(0xFF4E342E),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          ),
);
      },
    ),
  ],
),
      body: ValueListenableBuilder<List<Map<String, dynamic>>>(
        valueListenable: transactionHistory,
builder: (context, history, _) {

  // Winning में Txn number missing हो तो एक बार बना दो
  for (final item in history) {
    final itemTitle =
        (item['title'] ?? '').toString();

    final savedTxn =
        (item['txnNumber'] ?? '')
            .toString()
            .trim();

    if (itemTitle == 'Winning' &&
        savedTxn.isEmpty) {
      item['txnNumber'] =
          generateTxnNumber('WINNING');
    }
  }
final visibleHistory =
    history.reversed.take(100).toList();
  return ListView(
            padding: const EdgeInsets.all(16),
            children: [
             

             ...visibleHistory.asMap().entries.map((entry) {
  final index = entry.key;
  final item = entry.value;
                final String title =
                    (item['title'] ?? '').toString();
                final String subtitle =
                    (item['subtitle'] ?? '').toString();
                final String description =
                    (item['description'] ?? '').toString();
                final String winningType =
                    (item['winningType'] ?? '').toString();
                final dynamic rank = item['rank'];
                final String dateTime =
                    (item['dateTime'] ?? '').toString();
               final transactionDate =
    _parseHistoryDate(dateTime);

final previousItem =
    index > 0
        ? visibleHistory[index - 1]
        : null;

final previousDate =
    previousItem == null
        ? null
        : _parseHistoryDate(
            (previousItem['dateTime'] ?? '')
                .toString(),
          );

final bool showDateRibbon =
    transactionDate != null &&
    (previousDate == null ||
        !_isSameHistoryDay(
          transactionDate,
          previousDate,
        ));
final String txnNumber =
    (item['txnNumber'] ?? '').toString();
                final num amount =
                    (item['amount'] as num?) ?? 0;

                Color cardColor = const Color(0xFF4E342E);
                Color iconColor = Colors.white;
                Color textColor = Colors.white;
                Color subTextColor = Colors.white70;

                if (title == 'Deposit Approved') {
                  cardColor = const Color(0xFF1B5E20); // dark green
                  iconColor = Colors.lightGreenAccent;
                } else if (title == 'Withdraw Approved') {
                  cardColor = const Color(0xFF7F1D1D); // dark red
                  iconColor = Colors.redAccent;
                } else if (title == 'Contest Entry') {
                  cardColor = const Color(0xFF6D4C41); // dark brown/orange
                  iconColor = Colors.amberAccent;
                } else if (title == 'Winning') {
                  cardColor = const Color(0xFF283593); // dark blue
                  iconColor = Colors.lightBlueAccent;
                } else if (title == 'Deposit Reversed') {
                  cardColor = const Color(0xFF424242); // dark grey
                  iconColor = Colors.orangeAccent;
                } else if (title == 'Withdraw Reversed') {
                  cardColor = const Color(0xFF6A1B4D); // dark maroon/purple
                  iconColor = Colors.pinkAccent;
                }

                IconData leadingIcon = Icons.receipt_long;

                if (title == 'Contest Entry') {
                  leadingIcon = Icons.emoji_events;
                } else if (title == 'Deposit Approved') {
                  leadingIcon = Icons.arrow_downward;
                } else if (title == 'Withdraw Approved') {
                  leadingIcon = Icons.arrow_upward;
                } else if (title == 'Winning') {
                  leadingIcon = Icons.workspace_premium;
                } else if (title == 'Deposit Reversed' ||
                    title == 'Withdraw Reversed') {
                  leadingIcon = Icons.undo;
                }
String titleText =
    title == 'Winning' ? 'Winning Entry' : title;

String winningMatchText = description;

if (title == 'Winning' && description.trim().isNotEmpty) {
  try {
    final parts = description.split(
      RegExp(r'\s+vs\s+', caseSensitive: false),
    );

    if (parts.length == 2) {
      final team1Name = parts[0].trim();
      final team2Name = parts[1].trim();

      final match = adminMatches.value.firstWhere(
        (m) =>
            (m['team1'] ?? '')
                    .toString()
                    .trim()
                    .toLowerCase() ==
                team1Name.toLowerCase() &&
            (m['team2'] ?? '')
                    .toString()
                    .trim()
                    .toLowerCase() ==
                team2Name.toLowerCase(),
      );

      String shortName(String name) {
        final words =
            name.trim().split(RegExp(r'\s+'));

        if (words.length > 1) {
          return words
              .where((w) => w.isNotEmpty)
              .map((w) => w[0])
              .join()
              .toUpperCase();
        }

        return name.length <= 3
            ? name.toUpperCase()
            : name.substring(0, 3).toUpperCase();
      }

      final team1Logo =
          (match['team1Logo'] ?? '').toString();
      final team2Logo =
          (match['team2Logo'] ?? '').toString();
      final matchFormat =
          (match['matchFormat'] ?? 'T20').toString();

      winningMatchText =
          '$team1Logo ${shortName(team1Name)} '
          'vs ${shortName(team2Name)} $team2Logo'
          ' • $matchFormat';
    }
  } catch (_) {}
}

String subtitleText;

if (title == 'Winning') {
  subtitleText =
      '${txnNumber.isNotEmpty ? '$txnNumber\n' : ''}'
      '${subtitle.isNotEmpty ? subtitle : ''}'
      '${subtitle == 'Head to Head' &&
              winningType.trim().isNotEmpty
          ? ' • $winningType'
          : ''}'
      '${rank != null ? '\nRank: #$rank' : ''}'
      '${winningMatchText.isNotEmpty
          ? '\n$winningMatchText'
          : ''}'
      '${dateTime.isNotEmpty
          ? '\n⏰$dateTime'
          : ''}';
                
} else {
  subtitleText =
      '${txnNumber.isNotEmpty ? '$txnNumber\n' : ''}'
      '${subtitle.isNotEmpty ? subtitle : ''}'
      '${subtitle == 'Head to Head' &&
              winningType.trim().isNotEmpty
          ? ' • $winningType'
          : ''}'
      '${description.isNotEmpty ? '\n$description' : ''}'
      '${dateTime.isNotEmpty ? '\n⏰$dateTime' : ''}';
}
              return Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    if (showDateRibbon)
      _historyDateRibbon(transactionDate!),

    Card(
                  color: cardColor,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius:
    BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
  horizontal: 12,
  vertical: 0,
),
minVerticalPadding: 0,
visualDensity: const VisualDensity(
  vertical: -4,
),         
                    leading: Icon(
                      leadingIcon,
                      color: iconColor,
                      size: 26,
                    ),
                    title: Text(
                      titleText,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Padding(
  padding: const EdgeInsets.only(top: 1),
  child: title == 'Deposit Reversed'
      ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (txnNumber.isNotEmpty)
  Padding(
    padding: const EdgeInsets.only(bottom: 1),
    child: Text(
      txnNumber,
      style: TextStyle(
        color: subTextColor,
        fontSize: 13,
      ),
    ),
  ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 7,
vertical: 2,
              ),
              decoration: BoxDecoration(
                color: Colors.amber.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (dateTime.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Text(
                  '⏰$dateTime',
                  style: TextStyle(
                    color: subTextColor,
                    fontSize: 13,
                  ),
                ),
              ),
          ],
        )
      : Text(
          subtitleText,
          style: TextStyle(
            color: subTextColor,
            fontSize: 13,
height: 1.2,
          ),
        ),
),
                    trailing: Text(
                      "${amount >= 0 ? '+' : '-'}₹${amount.abs().toStringAsFixed(0)}",
                      style: TextStyle(
                        color: amount >= 0
                            ? Colors.lightGreenAccent
                            : Colors.redAccent.shade100,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    isThreeLine: false,
),
),
],
);
}),
              
                      
                

              if (history.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(30),
                  child: Center(child: Text('अभी कोई contest entry नहीं है')),
                ),
            ],
          );
        },
      ),
    );
  }
}

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: Icon(Icons.help_outline),
              title: Text('How to create a team?'),
              subtitle: Text(
                '11 players select करें, फिर Captain और Vice-Captain चुनें.',
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.emoji_events_outlined),
              title: Text('How to join a contest?'),
              subtitle: Text(
                'पहले team save करें, फिर View Contests में जाकर JOIN दबाएँ.',
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.account_balance_wallet_outlined),
              title: Text('Wallet'),
              subtitle: Text(
  'Wallet में Deposit और Withdraw request भेज सकते हैं। Admin approval के बाद balance और Transaction History update होगी।',
),
              ),
            ),
          
          Card(
            child: ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('About'),
subtitle: Text(
  'Fantasy Cricket में अपनी टीम बनाएं, contests join करें और leaderboard पर अपना rank देखें.',
         ),
    ),
  ),

  Card(
  child: Column(
    children: [
      ListTile(
        leading: const Icon(
          Icons.photo_camera_rounded,
          size: 30,
        ),
        title: const Text(
          'Instagram',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: const Text(
          '@CricNovaPlay',
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
        ),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Instagram: @CricNovaPlay',
              ),
            ),
          );
        },
      ),

      const Divider(
        height: 1,
      ),

      ListTile(
        leading: const Icon(
          Icons.telegram,
          size: 30,
        ),
        title: const Text(
          'Telegram',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: const Text(
          '@CricNovaPlay',
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
        ),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Telegram: @CricNovaPlay',
              ),
            ),
          );
        },
      ),
    ],
  ),
),     
        
      ],
    ),
  );
}
  }
class ReferEarnPage extends StatelessWidget {
  const ReferEarnPage({super.key});

  @override
  Widget build(BuildContext context) {
    const referralCode = 'CRICNOVA100';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Refer & Earn'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Icon(
            Icons.card_giftcard,
            size: 80,
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Invite Friends & Earn',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Center(
            child: Text(
              'Share your referral code with friends',
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('Your Referral Code'),
                  const SizedBox(height: 8),
                  const Text(
                    referralCode,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () {
  Clipboard.setData(
    const ClipboardData(text: 'CRICNOVA100'),
  );

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Referral code copied: CRICNOVA100'),
    ),
  );
},
                    icon: const Icon(Icons.copy),
                    label: const Text('COPY CODE'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
  Clipboard.setData(
    const ClipboardData(
      text:
          'Join CricNovaPlay using my referral code CRICNOVA100',
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        'Invite message copied — share it with your friends',
      ),
    ),
  );
},
            icon: const Icon(Icons.share),
            label: const Text('INVITE FRIENDS'),
          ),
          const SizedBox(height: 20),

const Card(
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Column(
      children: [
        Text(
          'Referral Rewards',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Icon(Icons.people, size: 32),
                SizedBox(height: 6),
                Text(
                  '0',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('Friends Joined'),
              ],
            ),

            Column(
              children: [
                Icon(Icons.currency_rupee, size: 32),
                SizedBox(height: 6),
                Text(
                  '₹0',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('Total Earnings'),
              ],
            ),
          ],
        ),
      ],
    ),
  ),
),
        ],
      ),
    );
  }
}
final ValueNotifier<List<Map<String, String>>> adminNotifications =
    ValueNotifier<List<Map<String, String>>>([]);
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children:  [
          ValueListenableBuilder<List<Map<String, String>>>(
  valueListenable: adminNotifications,
  builder: (context, notifications, _) {
    return Column(
      children: notifications
          .map(
            (item) => Card(
              child: ListTile(
                leading: const Icon(Icons.campaign),
                title: Text(item['title'] ?? ''),
                subtitle: Text(item['message'] ?? ''),
              ),
            ),
          )
          .toList(),
    );
  },
),
          Card(
            child: ListTile(
              leading: Icon(Icons.sports_cricket),
              title: Text('IND vs AUS'),
              subtitle: Text('Match starts today at 7:30 PM'),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.groups),
              title: Text('Team Reminder'),
              subtitle: Text('Create your team before the match starts.'),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.emoji_events),
              title: Text('Contest Update'),
subtitle: Text('New contests are available. Join before the match starts.'),
            ),
          ),
          Card(
  child: ListTile(
    leading: Icon(Icons.account_balance_wallet_outlined),
    title: Text('Wallet Update'),
    subtitle: Text(
      'Deposit, Withdraw या Winning update होने पर यहाँ notification दिखेगा.',
    ),
  ),
),
        ],
      ),
    );
  }
}
class AdminPlayerStatsPage extends StatelessWidget {
  const AdminPlayerStatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Player Stats'),
      ),
    body:  ValueListenableBuilder<List<Map<String, dynamic>>>(
        valueListenable: adminMatches,
        builder: (context, matches, _) {
          if (matches.isEmpty) {
            return const Center(
              child: Text(
                'No Matches Available',
                style: TextStyle(fontSize: 18),
              ),
            );
          }
final sortedMatches =
    List<Map<String, dynamic>>.from(matches);

DateTime getMatchDateTime(Map<String, dynamic> m) {
  try {
    final date = (m['date'] ?? '').toString().trim();
    final time = (m['time'] ?? '').toString().trim();

    final d = date.split('/');
    if (d.length != 3) return DateTime(1970);

    int hour = 0;
    int minute = 0;

    if (time.isNotEmpty) {
      final parts = time.split(' ');
      final hm = parts[0].split(':');

      hour = int.tryParse(hm[0]) ?? 0;
      minute =
          hm.length > 1 ? (int.tryParse(hm[1]) ?? 0) : 0;

      final amPm =
          parts.length > 1 ? parts[1].toUpperCase() : '';

      if (amPm == 'PM' && hour != 12) hour += 12;
      if (amPm == 'AM' && hour == 12) hour = 0;
    }

    return DateTime(
      int.parse(d[2]),
      int.parse(d[1]),
      int.parse(d[0]),
      hour,
      minute,
    );
  } catch (_) {
    return DateTime(1970);
  }
}

sortedMatches.sort(
  (a, b) =>
      getMatchDateTime(b).compareTo(getMatchDateTime(a)),
);
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: sortedMatches.length,
            itemBuilder: (context, index) {
        final match = sortedMatches[index];
                              final team1 = match['team1'] ?? '';
              final team2 = match['team2'] ?? '';
              final format =
    (match['matchFormat'] ?? '').toString().trim();
String makeShortName(String name) {
  final words = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((e) => e.isNotEmpty)
      .toList();

  if (words.isEmpty) return '';

  if (words.length == 1) {
    final word = words.first.toUpperCase();
    return word.length <= 3
        ? word
        : word.substring(0, 3);
  }

  return words
      .take(3)
      .map((e) => e[0].toUpperCase())
      .join();
}

final team1Short = makeShortName(team1.toString());
final team2Short = makeShortName(team2.toString());

final flag1 = (match['team1Logo'] ?? '').toString();
final flag2 = (match['team2Logo'] ?? '').toString();

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: const Icon(
                    Icons.sports_cricket,
                    size: 30,
                  ),
                  title: Text.rich(
  TextSpan(
    children: [
      TextSpan(
        text: '$flag1 $team1Short',
        style: const TextStyle(
          color: Color(0xFF3D2B2B),
          fontWeight: FontWeight.bold,
          fontSize: 17,
        ),
      ),
      const TextSpan(
        text: ' vs ',
        style: TextStyle(
          color: Color(0xFF6D4C41),
          fontWeight: FontWeight.bold,
          fontSize: 17,
        ),
      ),
      TextSpan(
        text: '$team2Short $flag2',
        style: const TextStyle(
          color: Color(0xFF3D2B2B),
          fontWeight: FontWeight.bold,
          fontSize: 17,
        ),
      ),
      if (format.isNotEmpty)
        TextSpan(
          text: '  •  $format',
          style: const TextStyle(
            color: Color(0xFFC65300),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
    ],
  ),
  maxLines: 2,
),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [      
                                          Text(
                      '${match['date'] ?? ''} • ${match['time'] ?? ''}',
                    ),
                    const SizedBox(height: 4),
                    Text(
                      match['status'] ?? 'UPCOMING',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                ),
                onTap: () {
                  _AdminMatchesPageState._updatePlayerStats(context, match);
                },
              ),
            );
          },
        );
      },
    ),
          );
  }
}
                  
class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
         Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    const Text(
      'Admin Controls',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    ),
    Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFEF3157),
            Color(0xFFC91F4A),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33C91F4A),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AdminMatchesPage(),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 11,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
  Icons.sports_cricket,
  size: 24,
  color: Colors.white,
),
            SizedBox(width: 8),
            Text(
              'Manage\nMatches',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                height: 1.05,
              ),
            ),
            SizedBox(width: 10),
            Icon(Icons.arrow_forward, size: 20),
          ],
        ),
      ),
    ),
  ],
),
    
    
const SizedBox(height: 20),
Card(
  child: ListTile(
    leading: const CircleAvatar(
      backgroundColor: Colors.orange,
      child: Icon(
        Icons.swap_vert,
        color: Colors.white,
      ),
    ),
    title: const Text('Wallet Requests'),
    subtitle: const Text('Deposit & Withdraw requests'),
    trailing: const Icon(Icons.chevron_right),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const AdminWalletRequestsPage(),
        ),
      );
    },
  ),
),
           
          Card(
  child: ListTile(
    leading: const CircleAvatar(
  backgroundColor: Colors.green,
  child: Icon(
    Icons.account_balance,
    color: Colors.white,
  ),
),
    title: const Text('Admin Wallet'),
    subtitle: const Text(
      'Approved deposit & withdraw history',
    ),
    trailing: const Icon(Icons.chevron_right),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const AdminWalletPage(),
        ),
      );
    },
  ),
),
          
   Card(
  child: ListTile(
    leading: const CircleAvatar(
      backgroundColor: Colors.purple,
      child: Icon(
        Icons.card_giftcard,
        color: Colors.white,
      ),
    ),
    title: const Text(
      'Bonus Management',
    ),
    subtitle: const Text(
      'Welcome Bonus & User Reward Bonus',
    ),
    trailing: const Icon(
      Icons.chevron_right,
    ),
    onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const BonusManagementPage(),
    ),
  );
},
  ),
),       
   
   Card(
  child: ListTile(
    leading: const CircleAvatar(
      backgroundColor: Colors.indigo,
      child: Icon(
        Icons.leaderboard,
        color: Colors.white,
      ),
    ),
    title: const Text(
      'User Activity',
    ),
    subtitle: const Text(
      'Top users & activity rankings',
    ),
    trailing: const Icon(
      Icons.chevron_right,
    ),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const UserActivityPage(),
        ),
      );
    },
  ),
),       
          
          
Card(
  child: ListTile(
   leading: const CircleAvatar(
  backgroundColor: Colors.blue,
  child: Icon(
    Icons.qr_code,
    color: Colors.white,
  ),
),
    title: const Text('Deposit Settings'),
    subtitle: const Text(
      'Payment image, copy line & warning',
    ),
    trailing: const Icon(Icons.chevron_right),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const AdminDepositSettingsPage(),
        ),
      );
    },
  ),
),



    
          Card(
  child: ListTile(
    leading: const CircleAvatar(
  backgroundColor: Colors.amber,
  child: Icon(
    Icons.emoji_events,
    color: Colors.white,
  ),
),
    title: const Text('Manage Contests'),
    subtitle: const Text('Create and manage contests'),
    trailing: const Icon(Icons.chevron_right),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const AdminContestsPage(),
        ),
      );
    },
  ),
),

Card(
  child: ListTile(
    leading: const CircleAvatar(
  backgroundColor: Colors.teal,
  child: Icon(
    Icons.query_stats,
    color: Colors.white,
  ),
),
    title: const Text('Manage Player Stats'),
    subtitle: const Text('Update runs, wickets, catches & points'),
    trailing: const Icon(Icons.chevron_right),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const AdminPlayerStatsPage(),
        ),
      );
    },
  ),
),
          
          Card(
  child: ListTile(
    leading: const CircleAvatar(
  backgroundColor: Colors.purple,
  child: Icon(
    Icons.people,
    color: Colors.white,
  ),
),
    title: const Text('Manage Users'),
    subtitle: const Text('View and manage users'),
    trailing: const Icon(Icons.chevron_right),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const AdminUsersPage(),
        ),
      );
    },
  ),
),

Card(
  child: ListTile(
    leading: const CircleAvatar(
  backgroundColor: Colors.deepOrange,
  child: Icon(
    Icons.notifications_active,
    color: Colors.white,
  ),
),
    title: const Text('Send Notifications'),
    subtitle: const Text('Send updates to users'),
    trailing: const Icon(Icons.chevron_right),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const AdminNotificationsPage(),
        ),
      );
    },
  ),
),
          Card(
  child: ListTile(
 leading: const CircleAvatar(
  backgroundColor: Colors.deepPurple,
  child: Icon(
    Icons.card_giftcard,
    color: Colors.white,
  ),
),
    title: const Text('Referral Settings'),
    subtitle: const Text('Manage referral rewards'),
    
    trailing: const Icon(Icons.chevron_right),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const ReferralSettingsPage(),
        ),
      );
    },
  ),
),
          Card(
  child: ListTile(
    leading: const CircleAvatar(
  backgroundColor: Colors.red,
  child: Icon(
    Icons.history,
    color: Colors.white,
  ),
),
    title: const Text('Referral History'),
    subtitle: const Text('View referral records'),
    trailing: const Icon(Icons.chevron_right),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const ReferralHistoryPage(),
        ),
      );
    },
  ),
),
     ],
),
);
  }
}
class ReferralHistoryPage extends StatelessWidget {
  const ReferralHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Referral History'),
      ),
      body: ValueListenableBuilder<List<Map<String, String>>>(
        valueListenable: referralHistory,
        builder: (context, history, _) {
          if (history.isEmpty) {
            return const Center(
              child: Text(
                'No referral history yet',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final item = history[index];

              return Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.person_add),
                  ),
                  title: Text(item['name'] ?? 'User'),
                  subtitle: Text(
                    'Referral Code: ${item['code'] ?? '-'}',
                  ),
                  trailing: Text(
                    '₹${item['reward'] ?? '0'}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
class ReferralSettingsPage extends StatefulWidget {
  const ReferralSettingsPage({super.key});

  @override
  State<ReferralSettingsPage> createState() =>
      _ReferralSettingsPageState();
}

class _ReferralSettingsPageState
    extends State<ReferralSettingsPage> {
  bool rewardEnabled = false;
  double rewardAmount = 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Referral Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: SwitchListTile(
                title: const Text('Referral Reward'),
                subtitle: Text(
                  rewardEnabled
                      ? 'Reward is ON'
                      : 'Reward is OFF',
                ),
                value: rewardEnabled,
                onChanged: (value) {
                  setState(() {
                    rewardEnabled = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),

            Card(
              child: ListTile(
                leading: const Icon(Icons.currency_rupee),
                title: const Text('Reward Amount'),
                subtitle: Text(
                  '₹${rewardAmount.toStringAsFixed(0)}',
                ),
                trailing: SizedBox(
                  width: 140,
                  child: Slider(
                    value: rewardAmount,
                    min: 10,
                    max: 500,
                    divisions: 10,
                    label: '₹${rewardAmount.toStringAsFixed(0)}',
                    onChanged: rewardEnabled
                        ? (value) {
                            setState(() {
                              rewardAmount = value;
                            });
                          }
                        : null,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        rewardEnabled
                            ? 'Referral reward saved: ₹${rewardAmount.toStringAsFixed(0)}'
                            : 'Referral reward turned OFF',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.save),
                label: const Text('SAVE SETTINGS'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
final ValueNotifier<List<Map<String, String>>> referralHistory =
    ValueNotifier<List<Map<String, String>>>([]);
void addReferralRecord({
  required String userName,
  required String referralCode,
  required double reward,
}) {
  referralHistory.value = [
    {
      'user': userName,
      'code': referralCode,
      'reward': '₹${reward.toStringAsFixed(0)}',
      'status': reward > 0 ? 'Reward Given' : 'No Reward',
    },
    ...referralHistory.value,
  ];
}
class AdminNotificationsPage extends StatefulWidget {
  const AdminNotificationsPage({super.key});

  @override
  State<AdminNotificationsPage> createState() =>
      _AdminNotificationsPageState();
}

class _AdminNotificationsPageState
    extends State<AdminNotificationsPage> {
  final TextEditingController titleController =
      TextEditingController();

  final TextEditingController messageController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Notifications'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Notification Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Notification Message',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.send),
                label: const Text('SEND NOTIFICATION'),
                onPressed: () {
                  if (titleController.text.trim().isEmpty ||
                      messageController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('Please enter title and message'),
                      ),
                    );
                    return;
                  }

            adminNotifications.value = [
  {
    'title': titleController.text.trim(),
    'message': messageController.text.trim(),
  },
  ...adminNotifications.value,         
];     
             hasUnreadNotification.value = true;     ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Notification sent successfully'),
                    ),
                  );

                  titleController.clear();
                  messageController.clear();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final ValueNotifier<List<Map<String, dynamic>>> appUsers =
    ValueNotifier<List<Map<String, dynamic>>>([
  {
    'id': 'USER001',
    'name': 'Fantasy Player',
    'username': '@CricNovaPlay',
    'mobile': '9876543210',
    'walletBalance': 0.0,
    'isBlocked': false,
  },
]);
    
class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  bool isUserBlocked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.person),
              ),
              title: const Text('Fantasy Player'),
              subtitle: const Text(
                '@CricNovaPlay\nMobile: 9876543210',
              ),
              isThreeLine: true,
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('User Details'),
                      content: const Text(
                        'Name: Fantasy Player\n'
                        'Username: @CricNovaPlay\n'
                        'Mobile: 9876543210',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('CLOSE'),
                        ),
                        ElevatedButton(
  onPressed: () {
    setState(() {
      isUserBlocked = !isUserBlocked;
    });

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isUserBlocked ? 'User blocked' : 'User unblocked',
        ),
      ),
    );
  },
  child: Text(
    isUserBlocked ? 'UNBLOCK' : 'BLOCK',
  ),
),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
final List<Map<String, dynamic>> createdContests = [];
class AdminContestsPage extends StatefulWidget {
  const AdminContestsPage({super.key});

  @override
  State<AdminContestsPage> createState() => _AdminContestsPageState();
}

class _AdminContestsPageState extends State<AdminContestsPage> {
  String makeShortName(String name) {
  final words = name.trim().split(RegExp(r'\s+'));

  if (words.length > 1) {
    return words
        .where((w) => w.isNotEmpty)
        .map((w) => w[0])
        .join()
        .toUpperCase();
  }

  return name.length <= 3
      ? name.toUpperCase()
      : name.substring(0, 3).toUpperCase();
}
  bool _isMatchStillUpcoming(Map<String, String> match) {
  try {
    final dateText =
        (match['date'] ?? '').trim();

    final timeText =
        (match['time'] ?? '').trim();

    if (dateText.isEmpty || timeText.isEmpty) {
      return false;
    }

    final dateParts = dateText.split('/');

    if (dateParts.length != 3) {
      return false;
    }

    final timeParts = timeText.split(' ');

    final hm = timeParts[0].split(':');

    if (hm.length != 2) {
      return false;
    }

    int hour = int.parse(hm[0]);
    final minute = int.parse(hm[1]);

    if (timeParts.length > 1) {
      final period = timeParts[1].toUpperCase();

      if (period == 'PM' && hour != 12) {
        hour += 12;
      }

      if (period == 'AM' && hour == 12) {
        hour = 0;
      }
    }

    final startTime = DateTime(
      int.parse(dateParts[2]),
      int.parse(dateParts[1]),
      int.parse(dateParts[0]),
      hour,
      minute,
    );

    return DateTime.now().isBefore(startTime);
  } catch (_) {
    return false;
  }
}
  @override
  Widget build(BuildContext context) {
    final sortedContests =
    List<Map<String, dynamic>>.from(createdContests);

DateTime contestDateTime(Map<String, dynamic> contest) {
  try {
    final match = adminMatches.value.firstWhere(
      (m) =>
          m['team1'] == contest['team1'] &&
          m['team2'] == contest['team2'],
    );

    final date = (match['date'] ?? '').toString();
    final time = (match['time'] ?? '').toString();

    final d = date.split('/');
    final t = time.split(':');

    if (d.length == 3 && t.length >= 2) {
      int hour = int.tryParse(t[0]) ?? 0;
      int minute =
          int.tryParse(t[1].replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

      final upperTime = time.toUpperCase();

      if (upperTime.contains('PM') && hour < 12) {
        hour += 12;
      }

      if (upperTime.contains('AM') && hour == 12) {
        hour = 0;
      }

      return DateTime(
        int.parse(d[2]),
        int.parse(d[1]),
        int.parse(d[0]),
        hour,
        minute,
      );
    }
  } catch (_) {}

  return DateTime(2000);
}

sortedContests.sort(
  (a, b) => contestDateTime(b).compareTo(contestDateTime(a)),
);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Contests'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Contest Management',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          Center(
  child: SizedBox(
    width: 260,
    height: 48,
    child: ElevatedButton.icon(
            onPressed: () async {
  
  final feeController = TextEditingController();
  final prizeController = TextEditingController();
  final spotsController = TextEditingController();
Map<String, String>? selectedMatch;
String selectedContestType = 'Mega Contest';
              String h2hWinningType = 'Winner Takes All';
  final List<Map<String, TextEditingController>>
    prizeSlabControllers = [
  {
    'from': TextEditingController(text: '1'),
    'to': TextEditingController(text: '1'),
    'amount': TextEditingController(),
  },
];
            FocusManager.instance.primaryFocus?.unfocus();
await Future.delayed(const Duration(milliseconds: 150)); 
              showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Create Contest'),
        content: StatefulBuilder(
  builder: (context, setDialogState) {
    return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
      DropdownButtonFormField<Map<String, String>>(
  initialValue: selectedMatch,
        isExpanded: true,
  decoration: const InputDecoration(
    labelText: 'Select Match',
    border: OutlineInputBorder(),
  ),
  items: adminMatches.value
    .where(
  (match) => _isMatchStillUpcoming(match),
)
    .map((match) {
      return DropdownMenuItem<Map<String, String>>(
        value: match,
        child: Text(
          '${match['team1Logo'] ?? ''} '
          '${makeShortName(match['team1'] ?? '')} vs '
          '${makeShortName(match['team2'] ?? '')} '
          '${match['team2Logo'] ?? ''} • '
          '${match['matchFormat'] ?? 'T20'}',
          overflow: TextOverflow.ellipsis,
        ),
      );
    })
    .toList(),
  onChanged: (value) {
    selectedMatch = value;
  },
),

const SizedBox(height: 12),
              DropdownButtonFormField<String>(
  initialValue: selectedContestType,
  decoration: const InputDecoration(
    labelText: 'Contest Type',
    border: OutlineInputBorder(),
  ),
  items: const [
    DropdownMenuItem(
      value: 'Mega Contest',
      child: Text('Mega Contest'),
    ),
    DropdownMenuItem(
      value: 'Small League',
      child: Text('Small League'),
    ),
    DropdownMenuItem(
  value: 'Head to Head',
  child: Text('Head to Head'),
),
  ],
  onChanged: (value) {
  if (value == null) return;

  setDialogState(() {
    selectedContestType = value;

    if (selectedContestType == 'Head to Head') {
      spotsController.text = '2';
    }
  });
},
),

if (selectedContestType == 'Head to Head') ...[
  const SizedBox(height: 12),
  DropdownButtonFormField<String>(
    initialValue: h2hWinningType,
    decoration: const InputDecoration(
      labelText: 'Winning Type',
      border: OutlineInputBorder(),
    ),
    items: const [
      DropdownMenuItem(
        value: 'Winner Takes All',
        child: Text('Winner Takes All'),
      ),
      DropdownMenuItem(
        value: 'Rank Wise',
        child: Text('Rank Wise'),
      ),
    ],
    onChanged: (value) {
      if (value == null) return;

      setDialogState(() {
        h2hWinningType = value;

        prizeSlabControllers.clear();

        if (value == 'Winner Takes All') {
          prizeSlabControllers.add({
            'from': TextEditingController(text: '1'),
            'to': TextEditingController(text: '1'),
            'amount': TextEditingController(),
          });
        } else {
          prizeSlabControllers.addAll([
            {
              'from': TextEditingController(text: '1'),
              'to': TextEditingController(text: '1'),
              'amount': TextEditingController(),
            },
            {
              'from': TextEditingController(text: '2'),
              'to': TextEditingController(text: '2'),
              'amount': TextEditingController(),
            },
          ]);
        }
      });
    },
  ),
],
              const SizedBox(height: 12),
              TextField(
                controller: feeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Entry Fee',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: prizeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Prize Pool',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: spotsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Total Spots',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

const Align(
  alignment: Alignment.centerLeft,
  child: Text(
    'Prize Slabs',
    style: TextStyle(
      fontWeight: FontWeight.bold,
    ),
  ),
),

const SizedBox(height: 10),

...prizeSlabControllers.map((slab) {
  return Row(
    children: [
      Expanded(
        child: TextField(
          controller: slab['from'],
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'From',
            border: OutlineInputBorder(),
          ),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: TextField(
          controller: slab['to'],
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'To',
            border: OutlineInputBorder(),
          ),
        ),
      ),
      const SizedBox(width: 8),
Expanded(
  child: TextField(
    controller: slab['amount'],
    keyboardType: TextInputType.number,
    decoration: const InputDecoration(
      labelText: '₹ Prize',
      border: OutlineInputBorder(),
    ),
  ),
),
const SizedBox(width: 4),
IconButton(
  tooltip: 'Delete Slab',
  icon: const Icon(
    Icons.delete_outline,
    color: Colors.red,
  ),
  onPressed: () {
    setDialogState(() {
      prizeSlabControllers.remove(slab);
    });
  },
),
],
  );
}),
          const SizedBox(height: 12),

OutlinedButton.icon(
  onPressed: () {
    setDialogState(() {
      prizeSlabControllers.add({
        'from': TextEditingController(),
        'to': TextEditingController(),
        'amount': TextEditingController(),
      });
    });
  },
  icon: const Icon(Icons.add),
  label: const Text('ADD PRIZE SLAB'),
),    
            ],
          ),
        );
  },
),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
  onPressed: () {
    
    if (selectedMatch == null ||
    !_isMatchStillUpcoming(selectedMatch!)) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        'LIVE या COMPLETED match में contest create नहीं कर सकते',
      ),
    ),
  );
  return;
}

final name = selectedContestType;
    final fee = feeController.text.trim();
    final prize = prizeController.text.trim();
    final spots = spotsController.text.trim();

    if (selectedMatch == null ||
    
    fee.isEmpty ||
    prize.isEmpty ||
    spots.isEmpty) {
  return;
}
final totalSpots = int.tryParse(spots);

final invalidSlab = prizeSlabControllers.any((slab) {
  final from =
      int.tryParse(slab['from']!.text.trim());
  final to =
      int.tryParse(slab['to']!.text.trim());
  final amount =
      double.tryParse(slab['amount']!.text.trim());

  return from == null ||
      to == null ||
      amount == null ||
      from < 1 ||
      to < from ||
      amount <= 0 ||
      totalSpots == null ||
      to > totalSpots;
});

if (invalidSlab) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        'Prize Slab की Rank और Amount सही भरें',
      ),
    ),
  );
  return;
}
    bool hasOverlap = false;

for (int i = 0; i < prizeSlabControllers.length; i++) {
  final fromA = int.parse(
    prizeSlabControllers[i]['from']!.text.trim(),
  );
  final toA = int.parse(
    prizeSlabControllers[i]['to']!.text.trim(),
  );

  for (int j = i + 1;
      j < prizeSlabControllers.length;
      j++) {
    final fromB = int.parse(
      prizeSlabControllers[j]['from']!.text.trim(),
    );
    final toB = int.parse(
      prizeSlabControllers[j]['to']!.text.trim(),
    );

    if (fromA <= toB && fromB <= toA) {
      hasOverlap = true;
      break;
    }
  }

  if (hasOverlap) break;
}

if (hasOverlap) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        'Prize Slab की Rank आपस में overlap नहीं हो सकती',
      ),
    ),
  );
  return;
}
    final prizePoolAmount = double.tryParse(prize);

double totalPrizePayout = 0;

for (final slab in prizeSlabControllers) {
  final from =
      int.parse(slab['from']!.text.trim());
  final to =
      int.parse(slab['to']!.text.trim());
  final amount =
      double.parse(slab['amount']!.text.trim());

  totalPrizePayout +=
      (to - from + 1) * amount;
}

if (prizePoolAmount == null ||
    prizePoolAmount <= 0 ||
    (totalPrizePayout - prizePoolAmount).abs() > 0.01) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        'Prize Pool ₹$prize और Prize Slabs total ₹${totalPrizePayout.toStringAsFixed(0)} बराबर होना चाहिए',
      ),
    ),
  );
  return;
}
    setState(() {
      createdContests.add({
  'match': selectedMatch!,
        'team1': selectedMatch!['team1'],
'team2': selectedMatch!['team2'],
        'id': DateTime.now().microsecondsSinceEpoch.toString(),
  'type': selectedContestType,
        'h2hWinningType': h2hWinningType,
  'name': name,
  'fee': fee,
  'prize': prize,
  'spots': spots,
        'prizeSlabs': prizeSlabControllers.map((slab) {
  return {
    'from': slab['from']!.text.trim(),
    'to': slab['to']!.text.trim(),
    'amount': slab['amount']!.text.trim(),
  };
}).toList(),
});
    });

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Contest "$name" created'),
      ),
    );
  },
  child: const Text('CREATE'),
),
        ],
      );
    },
  );
},
            icon: const Icon(Icons.add),
label: const Text('CREATE NEW CONTEST'),
style: ElevatedButton.styleFrom(
  backgroundColor: const Color(0xFF1B5E20),
  foregroundColor: Colors.white,
),
),
      ),
),
          const SizedBox(height: 20),

...(() {
  final groupedContests =
      <String, List<Map<String, dynamic>>>{};

  for (final contest in sortedContests) {
    final key =
        '${contest['team1']}|||${contest['team2']}';

    groupedContests
        .putIfAbsent(
          key,
          () => <Map<String, dynamic>>[],
        )
        .add(contest);
  }

  return groupedContests.entries.expand<Widget>((entry) {
    final matchContests = entry.value;
    final firstContest = matchContests.first;

    final matchData = firstContest['match'];

String format = '';
String date = '';
String time = '';

if (matchData is Map) {
  format =
      (matchData['matchFormat'] ??
              matchData['format'] ??
              '')
          .toString()
          .trim();

  date = (matchData['date'] ?? '')
      .toString()
      .trim();

  time = (matchData['time'] ?? '')
      .toString()
      .trim();
}

    final team1 =
    firstContest['team1']?.toString() ?? '';

final team2 =
    firstContest['team2']?.toString() ?? '';

final team1Short = makeShortName(team1);
final team2Short = makeShortName(team2);

final team1Flag =
    ((matchData is Map
                ? (matchData['team1Logo'] ??
                    matchData['team1Flag'])
                : null) ??
            firstContest['team1Logo'] ??
            firstContest['team1Flag'] ??
            '')
        .toString()
        .trim();

final team2Flag =
    ((matchData is Map
                ? (matchData['team2Logo'] ??
                    matchData['team2Flag'])
                : null) ??
            firstContest['team2Logo'] ??
            firstContest['team2Flag'] ??
            '')
        .toString()
        .trim();

final leftTeam = team1Flag.isNotEmpty
    ? '$team1Flag $team1Short'
    : team1Short;

final rightTeam = team2Flag.isNotEmpty
    ? '$team2Short $team2Flag'
    : team2Short;
    team2Flag.isNotEmpty ? '$team2 $team2Flag' : team2;

    return <Widget>[
      Container(
        width: double.infinity,
        margin: const EdgeInsets.only(
          top: 8,
          bottom: 10,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFFE3F2FD),
        ),
        child: Text(
          [
  '$leftTeam vs $rightTeam',
  if (format.isNotEmpty) format,
  if (date.isNotEmpty) date,
  if (time.isNotEmpty) time,
].join(' • '),
          style: const TextStyle(
  fontSize: 17,
  fontWeight: FontWeight.bold,
  color: Color(0xFF721D3A),
),
        ),
      ),

      ...matchContests.map(
        (contest) => Card(
          color: const Color(0xFFF3E5F5),
          
    margin: const EdgeInsets.only(bottom: 12),
    child: ListTile(
      leading: const Icon(Icons.emoji_events),
      title: Text(
  contest['name'] == 'Head to Head' &&
          (contest['h2hWinningType'] ?? contest['winningType'] ?? '')
              .toString()
              .trim()
              .isNotEmpty
      ? '${contest['name']} • ${contest['h2hWinningType'] ?? contest['winningType']}'
      : contest['name'],
        style: const TextStyle(
  fontWeight: FontWeight.bold,
  fontSize: 16,
  color: Color(0xFF4F3038),
),
      ),
      subtitle: Text(
        'Entry Fee: ₹${contest['fee']}\n'
        'Prize Pool: ₹${contest['prize']}\n'
        'Total Spots: ${contest['spots']}',
      ),
      isThreeLine: true,
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(contest['name']),
        content: const Text(
          'What do you want to do with this contest?',
        ),
        actions: [
          TextButton(
  onPressed: () {
    Navigator.of(context, rootNavigator: true).pop();
  },
  child: const Text('CLOSE'),
),
        
          TextButton(
 onPressed: () async {
  Navigator.pop(context);

  final joinedNotifier =
      contest['joinedNotifier']
          as ValueNotifier<int>?;

  final int joinedSpots =
      joinedNotifier?.value ?? 0;

  final double entryFee =
      double.tryParse(
        (contest['fee'] ?? '0').toString(),
      ) ??
      0.0;

  final double collectedAmount =
      joinedSpots * entryFee;

  final editPrizeController =
      TextEditingController(
    text: (contest['prize'] ?? '').toString(),
  );

  final editSpotsController =
      TextEditingController(
    text: (contest['spots'] ?? '').toString(),
  );

  final List<Map<String, TextEditingController>>
      editPrizeSlabControllers = [];

  final oldSlabs = contest['prizeSlabs'];

  if (oldSlabs is List) {
    for (final slab in oldSlabs) {
      if (slab is Map) {
        editPrizeSlabControllers.add({
          'from': TextEditingController(
            text:
                (slab['from'] ?? '').toString(),
          ),
          'to': TextEditingController(
            text:
                (slab['to'] ?? '').toString(),
          ),
          'amount': TextEditingController(
            text:
                (slab['amount'] ?? '').toString(),
          ),
        });
      }
    }
  }
     if (editPrizeSlabControllers.isEmpty) {
    editPrizeSlabControllers.add({
      'from':
          TextEditingController(text: '1'),
      'to':
          TextEditingController(text: '1'),
      'amount':
          TextEditingController(),
    });
  }

  FocusManager.instance.primaryFocus?.unfocus();

  await Future.delayed(
    const Duration(milliseconds: 150),
  );

  if (!mounted) return;

  showDialog(
    context: this.context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (
          dialogContext,
          setEditDialogState,
        ) {
          final int currentTotalSpots =
              int.tryParse(
                editSpotsController.text.trim(),
              ) ??
              0;

          final double currentPrizePool =
              double.tryParse(
                editPrizeController.text.trim(),
              ) ??
              0.0;

          final double possibleAdminEarning =
              collectedAmount -
                  currentPrizePool;

          return AlertDialog(
            title: const Text(
              'Edit Contest',
            ),

            content: SingleChildScrollView(
              child: Column(
                mainAxisSize:
                    MainAxisSize.min,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contest: ${contest['name']} 🔒',
                    style: const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),     
          Text(
                    'Entry Fee: ₹${entryFee.toStringAsFixed(0)} 🔒',
                  ),

                  const SizedBox(height: 14),

                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          Colors.green.shade50,
                      borderRadius:
                          BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            Colors.green.shade200,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Joined Spots: '
                          '$joinedSpots / '
                          '$currentTotalSpots',
                          style: const TextStyle(
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(
                          height: 5,
                        ),

                        Text(
                          'Collected: '
                          '₹${collectedAmount.toStringAsFixed(0)}',
                        ),

                        const SizedBox(
                          height: 5,
                        ),

                        Text(
                          'Admin Earning: '
                          '₹${possibleAdminEarning.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontWeight:
                                FontWeight.bold,
                            color:
                                possibleAdminEarning <
                                        0
                                    ? Colors.red
                                    : Colors
                                        .green
                                        .shade800,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
          TextField(
                    controller:
                        editPrizeController,
                    keyboardType:
                        TextInputType.number,
                    autocorrect: false,
                    enableSuggestions: false,
                    onChanged: (_) {
                      setEditDialogState(
                        () {},
                      );
                    },
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Prize Pool',
                      border:
                          OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller:
                        editSpotsController,
                    keyboardType:
                        TextInputType.number,
                    autocorrect: false,
                    enableSuggestions: false,
                    onChanged: (_) {
                      setEditDialogState(
                        () {},
                      );
                    },
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Total Spots',
                      border:
                          OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'Prize Slabs',
                    style: TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  ...editPrizeSlabControllers
                      .map((slab) {
                    return Padding(
                      padding:
                          const EdgeInsets.only(
                        bottom: 10,
                      ),
          child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller:
                                  slab['from'],
                              keyboardType:
                                  TextInputType
                                      .number,
                              autocorrect:
                                  false,
                              enableSuggestions:
                                  false,
                              decoration:
                                  const InputDecoration(
                                labelText:
                                    'From',
                                border:
                                    OutlineInputBorder(),
                              ),
                            ),
                          ),

                          const SizedBox(
                            width: 6,
                          ),

                          Expanded(
                            child: TextField(
                              controller:
                                  slab['to'],
                              keyboardType:
                                  TextInputType
                                      .number,
                              autocorrect:
                                  false,
                              enableSuggestions:
                                  false,
                              decoration:
                                  const InputDecoration(
                                labelText:
                                    'To',
                                border:
                                    OutlineInputBorder(),
                              ),
                            ),
                          ),

                          const SizedBox(
                            width: 6,
                          ),
          
          Expanded(
                            child: TextField(
                              controller:
                                  slab['amount'],
                              keyboardType:
                                  TextInputType
                                      .number,
                              autocorrect:
                                  false,
                              enableSuggestions:
                                  false,
                              decoration:
                                  const InputDecoration(
                                labelText: '₹',
                                border:
                                    OutlineInputBorder(),
                              ),
                            ),
                          ),

                          IconButton(
                            icon: const Icon(
                              Icons
                                  .delete_outline,
                              color:
                                  Colors.red,
                            ),
                            onPressed: () {
                              if (editPrizeSlabControllers
                                      .length <=
                                  1) {
                                return;
                              }

                              setEditDialogState(
                                () {
                                  editPrizeSlabControllers
                                      .remove(
                                    slab,
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  }),

                  OutlinedButton.icon(
                    onPressed: () {
                      setEditDialogState(
                        () {
                          editPrizeSlabControllers
                              .add({
                            'from':
                                TextEditingController(),
                            'to':
                                TextEditingController(),
                            'amount':
                                TextEditingController(),
                          });
                        },
                      );
                    },
          icon:
                        const Icon(Icons.add),
                    label: const Text(
                      'ADD PRIZE SLAB',
                    ),
                  ),
                ],
              ),
            ),

            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(
                    dialogContext,
                  );
                },
                child:
                    const Text('CANCEL'),
              ),

              ElevatedButton(
                onPressed: () {
                  final prizePool =
                      double.tryParse(
                    editPrizeController.text
                        .trim(),
                  );

                  final totalSpots =
                      int.tryParse(
                    editSpotsController.text
                        .trim(),
                  );

                  if (prizePool == null ||
                      prizePool <= 0) {
                    ScaffoldMessenger.of(
                      this.context,
                    ).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Prize Pool सही भरें',
                        ),
                      ),
                    );
                    return;
                  }

                  if (totalSpots == null ||
                      totalSpots <= 0) {
                    ScaffoldMessenger.of(
                      this.context,
                    ).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Total Spots सही भरें',
                        ),
                      ),
                    );
                    return;
                  }
// Joined से Total Spots कम नहीं हो सकते
                  if (totalSpots <
                      joinedSpots) {
                    ScaffoldMessenger.of(
                      this.context,
                    ).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Already $joinedSpots spots joined हैं। '
                          'Total Spots $joinedSpots से कम नहीं कर सकते।',
                        ),
                      ),
                    );
                    return;
                  }

                  // Join हो चुके हैं तो Prize Pool
                  // collected amount से ज्यादा नहीं होगा
                  if (joinedSpots > 0 &&
                      prizePool >
                          collectedAmount) {
                    ScaffoldMessenger.of(
                      this.context,
                    ).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Collected ₹${collectedAmount.toStringAsFixed(0)} है। '
                          'Prize Pool इससे ज्यादा नहीं हो सकता।',
                        ),
                      ),
                    );
                    return;
                  }

                  bool invalidSlab = false;
                  bool hasOverlap = false;
                  double totalPrizePayout =
                      0;

                  for (final slab
                      in editPrizeSlabControllers) {
                    final from =
                        int.tryParse(
                      slab['from']!
                          .text
                          .trim(),
                    );

                    final to =
                        int.tryParse(
                      slab['to']!
                          .text
                          .trim(),
                    );

                    final amount =
                        double.tryParse(
                      slab['amount']!
                          .text
                          .trim(),
                    );

                    if (from == null ||
                        to == null ||
                        amount == null ||
                        from < 1 ||
                        to < from ||
                        to > totalSpots ||
                        amount <= 0) {
                      invalidSlab = true;
                      break;
                    }

                    totalPrizePayout +=
                        (to - from + 1) *
                            amount;
                  }
          if (invalidSlab) {
                    ScaffoldMessenger.of(
                      this.context,
                    ).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Prize Slab की Rank, Amount और Total Spots सही भरें',
                        ),
                      ),
                    );
                    return;
                  }

                  for (int i = 0;
                      i <
                          editPrizeSlabControllers
                              .length;
                      i++) {
                    final fromA =
                        int.parse(
                      editPrizeSlabControllers[i]
                              ['from']!
                          .text
                          .trim(),
                    );

                    final toA =
                        int.parse(
                      editPrizeSlabControllers[i]
                              ['to']!
                          .text
                          .trim(),
                    );

                    for (int j = i + 1;
                        j <
                            editPrizeSlabControllers
                                .length;
                        j++) {
                      final fromB =
                          int.parse(
                        editPrizeSlabControllers[j]
                                ['from']!
                            .text
                            .trim(),
                      );

                      final toB =
                          int.parse(
                        editPrizeSlabControllers[j]
                                ['to']!
                            .text
                            .trim(),
                      );

                      if (fromA <= toB &&
                          fromB <= toA) {
                        hasOverlap =
                            true;
                        break;
                      }
                    }

                    if (hasOverlap) {
                      break;
                    }
                  }

                  if (hasOverlap) {
                    ScaffoldMessenger.of(
                      this.context,
                    ).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Prize Slab की Rank आपस में overlap नहीं हो सकती',
                        ),
                      ),
                    );
                    return;
                  }
          
          if ((totalPrizePayout -
                              prizePool)
                          .abs() >
                      0.01) {
                    ScaffoldMessenger.of(
                      this.context,
                    ).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Prize Pool ₹${prizePool.toStringAsFixed(0)} '
                          'और Prize Slabs ₹${totalPrizePayout.toStringAsFixed(0)} '
                          'बराबर होना चाहिए',
                        ),
                      ),
                    );
                    return;
                  }

                  final updatedPrize =
    editPrizeController.text.trim();

final updatedSpots =
    editSpotsController.text.trim();

final updatedSlabs =
    editPrizeSlabControllers.map((slab) {
  return {
    'from': slab['from']!.text.trim(),
    'to': slab['to']!.text.trim(),
    'amount': slab['amount']!.text.trim(),
  };
}).toList();

setState(() {
  contest['prize'] = updatedPrize;
  contest['prizePool'] = updatedPrize;

  contest['spots'] = updatedSpots;
  contest['totalSpots'] = updatedSpots;

  contest['prizeSlabs'] = updatedSlabs;
});

final String editedContestId =
    (contest['id'] ?? '').toString();

final updatedJoinedList =
    List<Map<String, dynamic>>.from(
  joinedContests.value,
);

for (final joined in updatedJoinedList) {
  final String joinedContestId =
      (joined['contestId'] ?? '').toString();

  if (editedContestId.isNotEmpty &&
      joinedContestId == editedContestId) {

    joined['prize'] = updatedPrize;

    joined['prizePool'] =
        double.tryParse(updatedPrize) ?? 0.0;

    final updatedSpotsNumber =
    int.tryParse(updatedSpots) ?? 0;

joined['spots'] = updatedSpotsNumber;

joined['totalSpots'] = updatedSpotsNumber;

    joined['prizeSlabs'] =
        List<dynamic>.from(updatedSlabs);
  }
}

joinedContests.value = [
  ...updatedJoinedList,
];

                  Navigator.pop(
                    dialogContext,
                  );

                  ScaffoldMessenger.of(
                    this.context,
                  ).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Contest Prize, Spots और Rank updated',
                      ),
                    ),
                  );
                },
                child:
                    const Text('SAVE'),
              ),
            ],
          );
        },
      );
    },
  );
},
                   
          
  child: const Text('EDIT'),
),
          TextButton(
            onPressed: () {
              Navigator.pop(context);

              setState(() {
                createdContests.remove(contest);
              });

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Contest deleted'),
                ),
              );
            },
            child: const Text('DELETE'),
          ),
        ],
      );
    },
  );
},
    ),
  ),
),
            ];
  }).toList();
})(),
],
      ),
    );
  }
}
class AdminWalletRequestsPage extends StatelessWidget {
  const AdminWalletRequestsPage({super.key});

  Future<void> approveRequest(
  BuildContext context,
  int index,
  Map<String, dynamic> request,
) async {
    final updated =
        List<Map<String, dynamic>>.from(walletRequests.value);
if (index < 0 || index >= updated.length) return;

final currentStatus =
    (updated[index]['status'] ?? 'PENDING')
        .toString()
        .toUpperCase();
final noteController =
    TextEditingController(text: 'Verified payment');

final adminNote = await showDialog<String>(
  context: context,
  builder: (context) {
    return AlertDialog(
      title: const Text('Admin Note'),
      content: TextField(
        controller: noteController,
        decoration: const InputDecoration(
          labelText: 'Note',
          hintText: 'Verified payment',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL'),
        ),
        ElevatedButton(
          onPressed: () {
            final note = noteController.text.trim();

            Navigator.pop(
              context,
              note.isEmpty ? 'Verified payment' : note,
            );
          },
          child: const Text('APPROVE'),
        ),
      ],
    );
  },
);

if (adminNote == null) return;
if (currentStatus != 'PENDING') {
  return;
}
    final String type = request['type'];
    final double amount = request['amount'];
final now = DateTime.now();
    if (type == 'DEPOSIT') {
      final txnNumber = generateTxnNumber('DEPOSIT');
      request['txnNumber'] = txnNumber;
      walletBalance.value += amount;
      transactionHistory.value = [
        ...transactionHistory.value,
        {
          'title': 'Deposit Approved',
'subtitle': 'Admin approved deposit request',
'dateTime':
    '${now.day.toString().padLeft(2, '0')}/'
    '${now.month.toString().padLeft(2, '0')}/'
    '${now.year}  '
    '${now.hour.toString().padLeft(2, '0')}:'
    '${now.minute.toString().padLeft(2, '0')}',
'amount': amount,
          'txnNumber': txnNumber,
        },
      ];
      ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text(
      'Deposit ₹${amount.toStringAsFixed(0)} approved',
    ),
  ),
);
      appNotifications.value = [
  ...appNotifications.value,
  {
    'title': 'Deposit Approved',
    'subtitle':
        '₹${amount.toStringAsFixed(0)} आपके wallet में add हो गए.',
    'icon': Icons.account_balance_wallet_outlined,
  },
];
      appNotifications.value = [
  ...appNotifications.value,
  {
    'title': 'Withdraw Approved',
    'subtitle':
        '₹${amount.toStringAsFixed(0)} आपके wallet से withdraw हुए.',
    'icon': Icons.account_balance_wallet_outlined,
  },
];
      hasUnreadNotification.value = true;
    } else if (type == 'WITHDRAW') {
      if (amount > walletBalance.value) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Insufficient wallet balance'),
          ),
        );
        return;
      }

      walletBalance.value -= amount;
      final txnNumber = generateTxnNumber('WITHDRAW');
                    transactionHistory.value = [
        ...transactionHistory.value,
        {
          'title': 'Withdraw Approved',
'subtitle': 'Admin approved withdraw request',
'dateTime':
    '${now.day.toString().padLeft(2, '0')}/'
    '${now.month.toString().padLeft(2, '0')}/'
    '${now.year}  '
    '${now.hour.toString().padLeft(2, '0')}:'
    '${now.minute.toString().padLeft(2, '0')}',
'amount': -amount,
          'txnNumber': txnNumber,
        },
      ];
      ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text(
      'Withdraw ₹${amount.toStringAsFixed(0)} approved',
    ),
  ),
);
      appNotifications.value = [
  {
    'title': 'Withdraw Approved',
    'subtitle':
        '₹${amount.toStringAsFixed(0)} आपके wallet से withdraw हुए.',
    'icon': Icons.account_balance_wallet_outlined,
  },
  ...appNotifications.value,
];

hasUnreadNotification.value = true;
    }
    
updated[index] = {
  ...updated[index],
  'status': 'APPROVED',
  'resolvedAt': now,
  'adminNote': adminNote,
};
   

    walletRequests.value = updated;
  }

  void rejectRequest(int index) {
    final updated =
        List<Map<String, dynamic>>.from(walletRequests.value);

    updated[index] = {
  ...updated[index],
  'status': 'REJECTED',
  'resolvedAt': DateTime.now(),
};

    walletRequests.value = updated;
    final rejected = updated[index];

final type =
    (rejected['type'] ?? '').toString();

final amount =
    double.tryParse(
      (rejected['amount'] ?? 0).toString(),
    ) ??
    0;

appNotifications.value = [
  {
    'title': type == 'DEPOSIT'
        ? 'Deposit Rejected'
        : 'Withdraw Rejected',
    'subtitle':
        '₹${amount.toStringAsFixed(0)} ${type.toLowerCase()} request reject कर दी गई।',
    'icon': Icons.cancel_outlined,
  },
  ...appNotifications.value,
];

hasUnreadNotification.value = true;
  }
    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: const Text('Admin Wallet Requests'),
),
      body: ValueListenableBuilder<List<Map<String, dynamic>>>(
        valueListenable: walletRequests,
        builder: (context, requests, _) {
          final pendingEntries = requests
    .asMap()
    .entries
    .where(
      (entry) =>
          (entry.value['status'] ?? 'PENDING')
              .toString()
              .toUpperCase() ==
          'PENDING',
    )
    .toList()
    .reversed
    .toList();

if (pendingEntries.isEmpty) {
  return const Center(
    child: Text(
      'No pending wallet requests',
      style: TextStyle(fontSize: 18),
    ),
  );
}

return ListView.builder(
  padding: const EdgeInsets.all(12),
  itemCount: pendingEntries.length,
  itemBuilder: (context, index) {
    final originalIndex = pendingEntries[index].key;
    final request = pendingEntries[index].value;

              final String type = request['type'];
              final double amount = request['amount'];
              final String status = request['status'];
final String? screenshot = request['screenshot'];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                           child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        type,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Amount: ₹${amount.toStringAsFixed(0)}',
                      ),
                      const SizedBox(height: 6),
                      Text(
  'Status: $status',
  style: TextStyle(
    fontWeight: FontWeight.bold,
    color: status == 'APPROVED'
        ? Colors.green
        : status == 'REJECTED'
            ? Colors.red
            : Colors.orange,
      ),
),
if (type == 'DEPOSIT' && screenshot != null)
  OutlinedButton.icon(
    onPressed: () {
  final image =
      (request['screenshot'] ?? '').toString();

  if (image.isEmpty) return;

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => PaymentScreenshotPage(
        screenshot: image,
      ),
    ),
  );
},
    icon: const Icon(Icons.image),
    label: const Text(
      'VIEW PAYMENT SCREENSHOT',
    ),
  ),

const SizedBox(height: 12),

if (status == 'PENDING')
  Row(
    children: [
Expanded(

  child: ElevatedButton(
    onPressed: status == 'PENDING'
        ? () {
            approveRequest(
              context,
              originalIndex,
              request,
            );
          }
        : null,
        child: const Text('APPROVE'),
  ),
),

const SizedBox(width: 10),

Expanded(
  child: OutlinedButton(
    onPressed: status == 'PENDING'
        ? () {
            rejectRequest(originalIndex);
          }
        : null,
    child: const Text('REJECT'),
  ),
),
    ],
  ),

                    ],
                  ),
                ),
              );
            },
          );
        },

          ),
    );
  }
}
 
class UserActivityPage extends StatefulWidget {
  const UserActivityPage({super.key});

  @override
  State<UserActivityPage> createState() =>
      _UserActivityPageState();
}

class _UserActivityPageState
    extends State<UserActivityPage> {
  int selectedDays = 7;

  
  final List<Map<String, dynamic>> filters = const [
    {
      'label': '7 Days',
      'days': 7,
    },
    {
      'label': '15 Days',
      'days': 15,
    },
    {
      'label': '30 Days',
      'days': 30,
    },
    {
      'label': '6 Months',
      'days': 180,
    },
    {
      'label': '12 Months',
      'days': 365,
    },
  ];

  double _toDouble(dynamic value) {
    if (value == null) return 0;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value.toString().replaceAll('₹', '').trim(),
        ) ??
        0;
  }

  DateTime? _getDate(Map<String, dynamic> item) {
    final dynamic value =
        item['dateTime'] ??
        item['createdAt'] ??
        item['requestedAt'] ??
        item['resolvedAt'] ??
        item['joinedAt'] ??
        item['date'];

    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return value;
    }

    final text = value.toString().trim();

    if (text.isEmpty) {
      return null;
    }

    final normalDate = DateTime.tryParse(text);

    if (normalDate != null) {
      return normalDate;
    }
final match = RegExp(
      r'^(\d{1,2})/(\d{1,2})/(\d{4})(?:\s+(\d{1,2}):(\d{1,2}))?',
    ).firstMatch(text);

    if (match != null) {
      final day =
          int.tryParse(match.group(1) ?? '') ?? 1;

      final month =
          int.tryParse(match.group(2) ?? '') ?? 1;

      final year =
          int.tryParse(match.group(3) ?? '') ?? 2000;

      final hour =
          int.tryParse(match.group(4) ?? '') ?? 0;

      final minute =
          int.tryParse(match.group(5) ?? '') ?? 0;

      return DateTime(
        year,
        month,
        day,
        hour,
        minute,
      );
    }

    return null;
  }

  bool _insideSelectedDays(
    Map<String, dynamic> item,
  ) {
    final date = _getDate(item);

    // पुराने records में date नहीं है तो
    // उनको hide नहीं करेंगे.
    if (date == null) {
      return true;
    }

    final now = DateTime.now();

    final startDate = now.subtract(
      Duration(days: selectedDays),
    );

    return date.isAfter(startDate) ||
        date.isAtSameMomentAs(startDate);
  }

  bool _belongsToUser(
    Map<String, dynamic> item,
    Map<String, dynamic> user,
  ) {
    final userId =
        (user['id'] ??
                user['userId'] ??
                user['uid'] ??
                '')
            .toString();

    final username =
        (user['username'] ?? '').toString();

    final itemUserId =
        (item['userId'] ??
                item['userID'] ??
                item['uid'] ??
                '')
            .toString();

    final itemUsername =
        (item['username'] ?? '').toString();

    if (itemUserId.isNotEmpty) {
      return itemUserId == userId;
    }

    if (itemUsername.isNotEmpty) {
      return itemUsername == username;
    }

    // अभी आपके app में single user data है,
    // इसलिए पुराने records उसी user को मिलेंगे.
    return appUsers.value.length <= 1;
  }
Map<String, dynamic> _calculateUserStats(
    Map<String, dynamic> user,
  ) {
    int contestsJoined = 0;

    double totalEntry = 0;
    double totalWinning = 0;
    double totalDeposits = 0;
    double totalWithdrawals = 0;
    double totalBonus = 0;

    for (final raw in transactionHistory.value) {
  final item =
      Map<String, dynamic>.from(raw);

  if (!_belongsToUser(item, user)) {
    continue;
  }

  if (!_insideSelectedDays(item)) {
    continue;
  }

  final title =
      (item['title'] ?? '')
          .toString()
          .toUpperCase();

  final type =
      (item['type'] ?? '')
          .toString()
          .toUpperCase();

  final isContestEntry =
      type == 'ENTRY' ||
      type == 'CONTEST_ENTRY' ||
      title == 'CONTEST ENTRY' ||
      title.contains('ENTRY FEE');

  if (isContestEntry) {
    contestsJoined++;

    totalEntry +=
        _toDouble(item['amount']).abs();
  }
}

    for (final raw in walletRequests.value) {
      final item =
          Map<String, dynamic>.from(raw);

      if (!_belongsToUser(item, user)) {
        continue;
      }

      if (!_insideSelectedDays(item)) {
        continue;
      }

      final status =
          (item['status'] ?? '')
              .toString()
              .toUpperCase();

      final type =
          (item['type'] ?? '')
              .toString()
              .toUpperCase();

      final amount =
    _toDouble(item['amount']).abs();

      if (status == 'APPROVED' &&
          type == 'DEPOSIT') {
        totalDeposits += amount;
      }
      if (status == 'REVERSED' &&
    type == 'DEPOSIT') {
  totalDeposits -= amount;
}

      if (status == 'APPROVED' &&
          (type == 'WITHDRAW' ||
              type == 'WITHDRAWAL')) {
        totalWithdrawals += amount;
      }
    }
for (final raw in bonusHistory.value) {
      final item =
          Map<String, dynamic>.from(raw);

      if (!_belongsToUser(item, user)) {
        continue;
      }

      if (!_insideSelectedDays(item)) {
        continue;
      }

      totalBonus +=
          _toDouble(item['amount']);
    }

    for (final raw
        in transactionHistory.value) {
      final item =
          Map<String, dynamic>.from(raw);

      if (!_belongsToUser(item, user)) {
        continue;
      }

      if (!_insideSelectedDays(item)) {
        continue;
      }

      final title =
          (item['title'] ?? '')
              .toString()
              .toUpperCase();
final type =
    (item['type'] ?? '')
        .toString()
        .toUpperCase();

if (type == 'WELCOME_BONUS' ||
    title == 'WELCOME BONUS') {
  totalBonus +=
      _toDouble(item['amount']);
}
      if (title == 'WINNING' ||
          title == 'WINNING ENTRY') {
        totalWinning +=
            _toDouble(item['amount']);
      }
    }

    double currentWallet = 0;

    if (appUsers.value.length <= 1) {
      currentWallet =
          walletBalance.value.toDouble();
    } else {
      currentWallet = _toDouble(
        user['walletBalance'] ??
            user['wallet'] ??
            user['balance'],
      );
    }

    return {
      'user': user,
      'wallet': currentWallet,
      'contestsJoined': contestsJoined,
      'winning': totalWinning,
      'totalEntry': totalEntry,
      'deposits': totalDeposits,
      'withdrawals': totalWithdrawals,
      'bonus': totalBonus,
    };
  }

  Widget _filterChip(
    String label,
    int days,
  ) {
    final selected =
        selectedDays == days;

    return Padding(
      padding:
          const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) {
          setState(() {
            selectedDays = days;
          });
        },
        selectedColor:
            const Color(0xFF4F5BD5),
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          color: selected
              ? Colors.white
              : const Color(0xFF555555),
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
        side: BorderSide(
          color: selected
              ? const Color(0xFF4F5BD5)
              : const Color(0xFFDADCE6),
        ),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(18),
        ),
      ),
    );
  }
Widget _smallStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      width: 116,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white
            .withOpacity(0.72),
        borderRadius:
            BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      const TextStyle(
                    fontSize: 9.5,
                    color:
                        Color(0xFF666666),
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  value,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      const TextStyle(
                    fontSize: 12,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        Color(0xFF252525),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _cardColor(int rank) {
    if (rank == 1) {
      return const Color(0xFFFFF1C5);
    }

    if (rank == 2) {
      return const Color(0xFFEAF0FA);
    }

    if (rank == 3) {
      return const Color(0xFFFBE4DA);
    }

    return Colors.white;
  }

  Color _rankColor(int rank) {
    if (rank == 1) {
      return const Color(0xFFE5A600);
    }

    if (rank == 2) {
      return const Color(0xFF73849A);
    }

    if (rank == 3) {
      return const Color(0xFFB46B47);
    }

    return const Color(0xFF5264D9);
  }

  String _rankIcon(int rank) {
    if (rank == 1) {
      return '👑';
    }

    if (rank == 2) {
      return '🥈';
    }

    if (rank == 3) {
      return '🥉';
    }

    return '';
  }
@override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>>
        users = appUsers.value
            .map(
              (e) =>
                  Map<String, dynamic>.from(e),
            )
            .toList();

    final List<Map<String, dynamic>>
        rankedUsers = users
            .map(_calculateUserStats)
            .toList();

    rankedUsers.sort((a, b) {
      final entryCompare =
          (b['totalEntry'] as double)
              .compareTo(
        a['totalEntry'] as double,
      );

      if (entryCompare != 0) {
        return entryCompare;
      }

      final joinedCompare =
          (b['contestsJoined'] as int)
              .compareTo(
        a['contestsJoined'] as int,
      );

      if (joinedCompare != 0) {
        return joinedCompare;
      }

      final winningCompare =
          (b['winning'] as double)
              .compareTo(
        a['winning'] as double,
      );

      if (winningCompare != 0) {
        return winningCompare;
      }

      return (b['wallet'] as double)
          .compareTo(
        a['wallet'] as double,
      );
    });

    final topUsers =
        rankedUsers.take(100).toList();

    return Scaffold(
      backgroundColor:
          const Color(0xFFF7F7FC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor:
            const Color(0xFFF7F7FC),
        foregroundColor:
            const Color(0xFF202020),
        title: const Text(
          'User Activity',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Padding(
            padding:
                const EdgeInsets.only(
              right: 16,
            ),
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color:
                      const Color(0xFFFFE7A6),
                  borderRadius:
                      BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Text(
                      '👑',
                      style:
                          TextStyle(fontSize: 15),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'TOP 100',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight:
                            FontWeight.bold,
                        color:
                            Color(0xFF805500),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding:
            const EdgeInsets.fromLTRB(
          16,
          8,
          16,
          30,
        ),
children: [
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient:
                  const LinearGradient(
                begin:
                    Alignment.topLeft,
                end:
                    Alignment.bottomRight,
                colors: [
                  Color(0xFF445BD4),
                  Color(0xFF744ED1),
                ],
              ),
              borderRadius:
                  BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(
                    0xFF5264D9,
                  ).withOpacity(0.22),
                  blurRadius: 18,
                  offset:
                      const Offset(0, 7),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration:
                      const BoxDecoration(
                    color: Colors.white,
                    shape:
                        BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      '🏆',
                      style: TextStyle(
                        fontSize: 35,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 13),
                const Text(
                  'Top Users',
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.white,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'User activity and rankings',
                  style: TextStyle(
                    fontSize: 14,
                    color:
                        Color(0xFFE5E8FF),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration:
                      BoxDecoration(
                    color: Colors.white
                        .withOpacity(0.16),
                    borderRadius:
                        BorderRadius.circular(
                      30,
                    ),
                  ),
                  child: const Text(
                    'Top 100 Active Users',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),
const Text(
            'Activity Period',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),

          const SizedBox(height: 9),

          SingleChildScrollView(
            scrollDirection:
                Axis.horizontal,
            child: Row(
              children: filters
                  .map(
                    (item) =>
                        _filterChip(
                      item['label']
                          .toString(),
                      item['days'] as int,
                    ),
                  )
                  .toList(),
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              const Expanded(
                child: Text(
                  'Leaderboard',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${topUsers.length} Users',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight:
                      FontWeight.w600,
                  color:
                      Color(0xFF777777),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (topUsers.isEmpty)
            Container(
              padding:
                  const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(
                  18,
                ),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.groups_rounded,
                    size: 45,
                    color:
                        Color(0xFF9CA4D9),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'No users found',
                    style: TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
...topUsers
              .asMap()
              .entries
              .map((entry) {
            final rank =
                entry.key + 1;

            final stats =
                entry.value;

            final user =
                stats['user']
                    as Map<String, dynamic>;

            final name =
                (user['name'] ??
                        'User')
                    .toString();

            final username =
                (user['username'] ??
                        '')
                    .toString();

            final id =
                (user['id'] ??
                        user['userId'] ??
                        '')
                    .toString();

            return Container(
              margin:
                  const EdgeInsets.only(
                bottom: 13,
              ),
              decoration: BoxDecoration(
                color: _cardColor(rank),
                borderRadius:
                    BorderRadius.circular(
                  20,
                ),
                border: Border.all(
                  color:
                      _rankColor(rank)
                          .withOpacity(
                    rank <= 3
                        ? 0.30
                        : 0.12,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withOpacity(0.06),
                    blurRadius: 10,
                    offset:
                        const Offset(0, 4),
                  ),
                ],
              ),
child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            UserActivityDetailPage(
                          user: user,
                          stats: stats,
                          selectedDays:
                              selectedDays,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding:
                        const EdgeInsets.all(
                      14,
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration:
                                  BoxDecoration(
                                color:
                                    _rankColor(
                                  rank,
                                ),
                                shape:
                                    BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '#$rank',
                                  style:
                                      const TextStyle(
                                    color:
                                        Colors.white,
                                    fontWeight:
                                        FontWeight.bold,
                                    fontSize:
                                        16,
                                  ),
                                ),
                              ),
                            ),
const SizedBox(
                              width: 11,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          name,
                                          maxLines:
                                              1,
                                          overflow:
                                              TextOverflow
                                                  .ellipsis,
                                          style:
                                              const TextStyle(
                                            fontSize:
                                                17,
                                            fontWeight:
                                                FontWeight
                                                    .bold,
                                          ),
                                        ),
                                      ),
                                      if (rank <=
                                          3) ...[
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          _rankIcon(
                                            rank,
                                          ),
                                          style:
                                              const TextStyle(
                                            fontSize:
                                                18,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
const SizedBox(
                                    height: 2,
                                  ),
                                  Text(
                                    '$username'
                                    '${username.isNotEmpty && id.isNotEmpty ? ' • ' : ''}'
                                    '$id',
                                    maxLines: 1,
                                    overflow:
                                        TextOverflow
                                            .ellipsis,
                                    style:
                                        const TextStyle(
                                      color:
                                          Color(
                                        0xFF6C6C6C,
                                      ),
                                      fontSize:
                                          12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 34,
                              height: 34,
                              decoration:
                                  BoxDecoration(
                                color: Colors.white
                                    .withOpacity(
                                  0.75,
                                ),
                                shape:
                                    BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons
                                    .chevron_right_rounded,
                                size: 24,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 13,
                        ),

                        Wrap(
                          spacing: 7,
                          runSpacing: 7,
                          children: [
                            _smallStat(
                              icon: Icons
                                  .account_balance_wallet_rounded,
                              label:
                                  'Wallet',
                              value:
                                  '₹${(stats['wallet'] as double).toStringAsFixed(0)}',
                              color:
                                  Colors.blue,
                            ),
_smallStat(
                              icon: Icons
                                  .groups_rounded,
                              label:
                                  'Joined',
                              value:
                                  '${stats['contestsJoined']}',
                              color:
                                  Colors.purple,
                            ),
                            _smallStat(
                              icon: Icons
                                  .emoji_events_rounded,
                              label:
                                  'Winning',
                              value:
                                  '₹${(stats['winning'] as double).toStringAsFixed(0)}',
                              color:
                                  Colors.amber
                                      .shade800,
                            ),
                            _smallStat(
                              icon: Icons
                                  .currency_rupee_rounded,
                              label:
                                  'Total Entry',
                              value:
                                  '₹${(stats['totalEntry'] as double).toStringAsFixed(0)}',
                              color:
                                  Colors.orange,
                            ),
                            _smallStat(
                              icon: Icons
                                  .add_circle_rounded,
                              label:
                                  'Deposits',
                              value:
                                  '₹${(stats['deposits'] as double).toStringAsFixed(0)}',
                              color:
                                  Colors.green,
                            ),
                            _smallStat(
                              icon: Icons
                                  .arrow_circle_down_rounded,
                              label:
                                  'Withdrawals',
                              value:
                                  '₹${(stats['withdrawals'] as double).toStringAsFixed(0)}',
                              color:
                                  Colors.red,
                            ),
                            _smallStat(
                              icon: Icons
                                  .card_giftcard_rounded,
                              label:
                                  'Bonus',
                              value:
                                  '₹${(stats['bonus'] as double).toStringAsFixed(0)}',
                              color:
                                  Colors.pink,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}


// ======================================================
// USER ACTIVITY DETAIL PAGE
// Right arrow दबाने पर यह page खुलेगा
// ======================================================

class UserActivityDetailPage
    extends StatelessWidget {
  final Map<String, dynamic> user;
  final Map<String, dynamic> stats;
  final int selectedDays;

  const UserActivityDetailPage({
    super.key,
    required this.user,
    required this.stats,
    required this.selectedDays,
  });

  double _toDouble(dynamic value) {
    if (value == null) return 0;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value.toString().replaceAll(
            '₹',
            '',
          ),
        ) ??
        0;
  }

  DateTime? _getDate(
    Map<String, dynamic> item,
  ) {
    final value =
        item['dateTime'] ??
        item['createdAt'] ??
        item['resolvedAt'] ??
        item['requestedAt'] ??
        item['date'];

    if (value == null) return null;

    if (value is DateTime) {
      return value;
    }

    final text =
        value.toString().trim();

    final parsed =
        DateTime.tryParse(text);

    if (parsed != null) {
      return parsed;
    }

    final match = RegExp(
      r'^(\d{1,2})/(\d{1,2})/(\d{4})(?:\s+(\d{1,2}):(\d{1,2}))?',
    ).firstMatch(text);

    if (match == null) {
      return null;
    }

    return DateTime(
      int.tryParse(
            match.group(3) ?? '',
          ) ??
          2000,
      int.tryParse(
            match.group(2) ?? '',
          ) ??
          1,
      int.tryParse(
            match.group(1) ?? '',
          ) ??
          1,
      int.tryParse(
            match.group(4) ?? '',
          ) ??
          0,
      int.tryParse(
            match.group(5) ?? '',
          ) ??
          0,
    );
  }

bool _insidePeriod(
    Map<String, dynamic> item,
  ) {
    final date = _getDate(item);

    if (date == null) {
      return true;
    }

    return date.isAfter(
      DateTime.now().subtract(
        Duration(days: selectedDays),
      ),
    );
  }

  bool _belongsToUser(
    Map<String, dynamic> item,
  ) {
    final userId =
        (user['id'] ??
                user['userId'] ??
                user['uid'] ??
                '')
            .toString();

    final username =
        (user['username'] ?? '')
            .toString();

    final itemUserId =
        (item['userId'] ??
                item['userID'] ??
                item['uid'] ??
                '')
            .toString();

    final itemUsername =
        (item['username'] ?? '')
            .toString();

    if (itemUserId.isNotEmpty) {
      return itemUserId == userId;
    }

    if (itemUsername.isNotEmpty) {
      return itemUsername == username;
    }

    return appUsers.value.length <= 1;
  }

  Widget _bigBox({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 6,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius:
              BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 25,
            ),
            const SizedBox(height: 6),
            Text(
              value,
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                color: color,
                fontSize: 17,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                fontSize: 10,
                color:
                    Color(0xFF666666),
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
Widget _detailBox({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      width: 145,
      padding:
          const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color:
              color.withOpacity(0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 21,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style:
                const TextStyle(
              fontSize: 11,
              color:
                  Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final name =
        (user['name'] ?? 'User')
            .toString();

    final username =
        (user['username'] ?? '')
            .toString();

    final id =
        (user['id'] ??
                user['userId'] ??
                '')
            .toString();

    final wallet =
        stats['wallet'] as double;

    final joined =
        stats['contestsJoined'] as int;

    final winning =
        stats['winning'] as double;

    final totalEntry =
        stats['totalEntry'] as double;

    final deposits =
        stats['deposits'] as double;

    final withdrawals =
        stats['withdrawals'] as double;

    final bonus =
        stats['bonus'] as double;

    final List<Map<String, dynamic>>
        activities = [];

    for (final raw
        in transactionHistory.value) {
      final item =
          Map<String, dynamic>.from(raw);

      if (!_belongsToUser(item)) {
        continue;
      }

      if (!_insidePeriod(item)) {
        continue;
      }

      activities.add(item);
    }

    activities.sort((a, b) {
      final da = _getDate(a);
      final db = _getDate(b);

      if (da == null && db == null) {
        return 0;
      }

      if (da == null) return 1;
      if (db == null) return -1;

      return db.compareTo(da);
    });

    return Scaffold(
      backgroundColor:
          const Color(0xFFF7F7FC),
      appBar: AppBar(
        backgroundColor:
            const Color(0xFFF7F7FC),
        foregroundColor:
            const Color(0xFF222222),
        elevation: 0,
        title: const Text(
          'User Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: const [
          Padding(
            padding:
                EdgeInsets.only(
              right: 18,
            ),
            child: Center(
              child: Text(
                '👑',
                style: TextStyle(
                  fontSize: 24,
                ),
              ),
            ),
          ),
        ],
      ),
  body: ListView(
        padding:
            const EdgeInsets.fromLTRB(
          16,
          8,
          16,
          30,
        ),
        children: [
          Container(
            padding:
                const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient:
                  const LinearGradient(
                begin:
                    Alignment.topLeft,
                end:
                    Alignment.bottomRight,
                colors: [
                  Color(0xFF263B8F),
                  Color(0xFF6041B5),
                ],
              ),
              borderRadius:
                  BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration:
                      const BoxDecoration(
                    color: Colors.white,
                    shape:
                        BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    size: 48,
                    color:
                        Color(0xFF5264D9),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  name,
                  style:
                      const TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$username'
                  '${username.isNotEmpty && id.isNotEmpty ? ' • ' : ''}'
                  '$id',
                  style:
                      const TextStyle(
                    color:
                        Color(0xFFDDE2FF),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration:
                      BoxDecoration(
                    color:
                        const Color(
                      0xFF37B768,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      20,
                    ),
                  ),
                  child: const Text(
                    '● Active User',
                    style:
                        TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
  const SizedBox(height: 16),

          Row(
            children: [
              _bigBox(
                icon: Icons
                    .account_balance_wallet_rounded,
                value:
                    '₹${wallet.toStringAsFixed(0)}',
                label: 'User Wallet',
                color: Colors.blue,
              ),
              const SizedBox(width: 8),
              _bigBox(
                icon:
                    Icons.groups_rounded,
                value: '$joined',
                label:
                    'Contests Joined',
                color: Colors.purple,
              ),
              const SizedBox(width: 8),
              _bigBox(
                icon: Icons
                    .emoji_events_rounded,
                value:
                    '₹${winning.toStringAsFixed(0)}',
                label:
                    'Total Winning',
                color:
                    Colors.amber.shade800,
              ),
            ],
          ),

          const SizedBox(height: 15),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _detailBox(
                icon: Icons
                    .currency_rupee_rounded,
                label: 'Total Entry',
                value:
                    '₹${totalEntry.toStringAsFixed(0)}',
                color: Colors.orange,
              ),
              _detailBox(
                icon: Icons
                    .add_circle_rounded,
                label: 'Deposits',
                value:
                    '₹${deposits.toStringAsFixed(0)}',
                color: Colors.green,
              ),
              _detailBox(
                icon: Icons
                    .arrow_circle_down_rounded,
                label: 'Withdrawals',
                value:
                    '₹${withdrawals.toStringAsFixed(0)}',
                color: Colors.red,
              ),
              _detailBox(
                icon: Icons
                    .card_giftcard_rounded,
                label:
                    'Bonus Received',
                value:
                    '₹${bonus.toStringAsFixed(0)}',
                color: Colors.pink,
              ),
            ],
          ),

          const SizedBox(height: 22),

          Row(
            children: [
              const Expanded(
                child: Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
  Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xFFE9ECFF,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                ),
                child: Text(
                  selectedDays == 180
                      ? '6 Months'
                      : selectedDays ==
                              365
                          ? '12 Months'
                          : '$selectedDays Days',
                  style:
                      const TextStyle(
                    color:
                        Color(0xFF4F5BD5),
                    fontSize: 11,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (activities.isEmpty)
            Container(
              padding:
                  const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(
                  18,
                ),
              ),
              child: const Center(
                child: Text(
                  'No recent activity',
                  style: TextStyle(
                    color:
                        Color(0xFF777777),
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ),
            ),
  ...activities.take(30).map(
            (item) {
              final title =
                  (item['title'] ??
                          'Transaction')
                      .toString();

              final upper =
                  title.toUpperCase();

              final amount =
                  _toDouble(
                item['amount'],
              ).abs();

              final isOut =
                  upper.contains(
                        'WITHDRAW',
                      ) ||
                      upper.contains(
                        'CONTEST ENTRY',
                      ) ||
                      upper.contains(
                        'REVERSED',
                      );

              IconData icon =
                  Icons.receipt_long_rounded;

              Color color =
                  const Color(0xFF5264D9);

              if (upper.contains(
                'WINNING',
              )) {
                icon = Icons
                    .emoji_events_rounded;
                color = Colors.green;
              } else if (upper.contains(
                'DEPOSIT',
              )) {
                icon = Icons
                    .add_circle_rounded;
                color = Colors.green;
              } else if (upper.contains(
                'WITHDRAW',
              )) {
                icon = Icons
                    .arrow_circle_down_rounded;
                color = Colors.red;
              } else if (upper.contains(
                'BONUS',
              )) {
                icon = Icons
                    .card_giftcard_rounded;
                color = Colors.pink;
              } else if (upper.contains(
                'CONTEST',
              )) {
                icon = Icons
                    .sports_cricket_rounded;
                color = Colors.orange;
              }

              return Container(
                margin:
                    const EdgeInsets.only(
                  bottom: 9,
                ),
                padding:
                    const EdgeInsets.all(
                  13,
                ),
                decoration:
                    BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black
                              .withOpacity(
                        0.04,
                      ),
                      blurRadius: 8,
                      offset:
                          const Offset(
                        0,
                        3,
                      ),
                    ),
                  ],
                ),
  child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration:
                          BoxDecoration(
                        color: color
                            .withOpacity(
                          0.11,
                        ),
                        shape:
                            BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 22,
                      ),
                    ),
                    const SizedBox(
                      width: 11,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Text(
                            title,
                            style:
                                const TextStyle(
                              fontSize: 14,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            height: 3,
                          ),
                          Text(
                            (item['dateTime'] ??
                                    item['resolvedAt'] ??
                                    item['requestedAt'] ??
                                    '')
                                .toString(),
                            style:
                                const TextStyle(
                              fontSize: 11,
                              color:
                                  Color(
                                0xFF777777,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
  Text(
                      '${isOut ? '-' : '+'}₹${amount.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontWeight:
                            FontWeight.bold,
                        fontSize: 14,
                        color: isOut
                            ? Colors.red
                            : Colors.green,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class BonusManagementPage extends StatelessWidget {
  const BonusManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bonus Management'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.orange,
                  child: Icon(
                    Icons.card_giftcard,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Bonus Management',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Welcome Bonus & User Reward Bonus',
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

                      const SizedBox(height: 18),

            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.orange,
                  child: Icon(
                    Icons.celebration,
                    color: Colors.white,
                  ),
                ),
                title: const Text(
                  'Welcome Bonus Settings',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text(
                  'New users welcome bonus amount',
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const WelcomeBonusSettingsPage(),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.purple,
                  child: Icon(
                    Icons.card_giftcard,
                    color: Colors.white,
                  ),
                ),
                title: const Text(
                  'Give User Bonus',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text(
                  'Search user and give reward bonus',
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const GiveUserBonusPage(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
  }
}


final ValueNotifier<double> welcomeBonusAmount =
    ValueNotifier<double>(20);

class WelcomeBonusSettingsPage extends StatelessWidget {
  const WelcomeBonusSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController amountController =
        TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome Bonus Settings'),
      ),
      body: SingleChildScrollView(
  child: Padding(
        padding: const EdgeInsets.all(16),
        child: ValueListenableBuilder<double>(
          valueListenable: welcomeBonusAmount,
          builder: (context, amount, _) {
            return Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 28,
                        backgroundColor:
                            Colors.orange,
                        child: Icon(
                          Icons.celebration,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Current Welcome Bonus',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '₹${amount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
const SizedBox(height: 24),

                TextField(
                  controller: amountController,
                  keyboardType:
                      TextInputType.number,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'New Welcome Bonus Amount',
                    prefixText: '₹ ',
                    border:
                        OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final newAmount =
                          double.tryParse(
                        amountController.text
                            .trim(),
                      );

                      if (newAmount == null ||
                          newAmount < 0) {
                        ScaffoldMessenger.of(
                                context)
                            .showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Valid bonus amount enter करें',
                            ),
                          ),
                        );
                        return;
                      }

                      welcomeBonusAmount.value =
                          newAmount;

                      amountController.clear();

                      ScaffoldMessenger.of(
                              context)
                          .showSnackBar(
                        SnackBar(
                          content: Text(
                            'Welcome Bonus ₹${newAmount.toStringAsFixed(0)} set हो गया',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.save,
                    ),
                    label: const Text(
                      'SAVE WELCOME BONUS',
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
       ), 
    );
  }
}

class GiveUserBonusPage extends StatefulWidget {
  const GiveUserBonusPage({super.key});

  @override
  State<GiveUserBonusPage> createState() =>
      _GiveUserBonusPageState();
}

class _GiveUserBonusPageState
    extends State<GiveUserBonusPage> {

  String? selectedBonusUsername;
String userSearchText = '';
  @override
  Widget build(BuildContext context) {
    final TextEditingController amountController =
        TextEditingController();

    final TextEditingController noteController =
        TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Give User Bonus'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFF3E8FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.purple,
                    child: Icon(
                      Icons.card_giftcard,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Reward Bonus',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Give bonus to current user',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),
            Container(
  width: double.infinity,
  padding: const EdgeInsets.all(14),
  decoration: BoxDecoration(
    color: Colors.blueGrey.shade50,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: Colors.blueGrey.shade200,
    ),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Select User',
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
      ),

      const SizedBox(height: 10),

      TextField(
        decoration: const InputDecoration(
          hintText: 'Search username or User ID',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
          isDense: true,
        ),
        onChanged: (value) {
  setState(() {
    userSearchText = value.trim().toLowerCase();
    selectedBonusUsername = null;
  });
},
      ),

      const SizedBox(height: 10),
if (userSearchText.isNotEmpty)
  ...appUsers.value.where((user) {
    final name =
        (user['name'] ?? '').toString().toLowerCase();

    final username =
        (user['username'] ?? '').toString().toLowerCase();

    final userId =
        (user['id'] ?? '').toString().toLowerCase();

    return name.contains(userSearchText) ||
        username.contains(userSearchText) ||
        userId.contains(userSearchText);
  }).map((user) {
    final username =
        (user['username'] ?? '').toString();

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        dense: true,
        leading: const CircleAvatar(
          child: Icon(Icons.person),
        ),
        title: Text(
          (user['name'] ?? 'User').toString(),
        ),
        subtitle: Text(
          '$username • ${(user['id'] ?? '').toString()}',
        ),
        trailing: const Icon(
          Icons.check_circle_outline,
        ),
        onTap: () {
          setState(() {
            selectedBonusUsername = username;
            userSearchText = '';
          });
        },
      ),
    );
  }),
      if (selectedBonusUsername == null)
        const Text(
          'Bonus देने के लिए पहले user select करें',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey,
          ),
        ),
      
      if (selectedBonusUsername != null)
  Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.green.shade50,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: Colors.green.shade200,
      ),
    ),
    child: Row(
      children: [
        const CircleAvatar(
          backgroundColor: Colors.green,
          child: Icon(
            Icons.check,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Selected User',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              Text(
                selectedBonusUsername!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              selectedBonusUsername = null;
            });
          },
          icon: const Icon(Icons.close),
        ),
      ],
    ),
  ),
    ],
  ),
),

const SizedBox(height: 18),
            
TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Bonus Amount',
                prefixText: '₹ ',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 14),

            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                labelText: 'Admin Note',
                hintText: 'Example: Active user reward',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  final amount = double.tryParse(
                    amountController.text.trim(),
                  );
                  if (selectedBonusUsername == null) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        'पहले user select करें',
      ),
    ),
  );
  return;
}

                  if (amount == null || amount <= 0) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Valid bonus amount enter करें',
                        ),
                      ),
                    );
                    return;
                  }

                  final now = DateTime.now();

final note =
    noteController.text.trim().isEmpty
        ? 'Admin reward bonus'
        : noteController.text.trim();

final double balanceBefore =
    walletBalance.value;

final double balanceAfter =
    balanceBefore + amount;

walletBalance.value = balanceAfter;

final bonusList =
    List<Map<String, dynamic>>.from(
  bonusHistory.value,
);
final txnNumber =
    generateTxnNumber('BONUS');
bonusList.add({
  'type': 'USER_BONUS',
  'txnNumber': txnNumber,
  'username': selectedBonusUsername!,
  'amount': amount,
  'note': note,
  'createdAt': now,
  'balanceBefore': balanceBefore,
  'balanceAfter': balanceAfter,
});

bonusHistory.value = bonusList;

                  transactionHistory.value = [
                    ...transactionHistory.value,
                    {
                      'title': 'Admin Bonus',
                      'txnNumber': txnNumber,
                      'subtitle': note,
                      'dateTime':
                          '${now.day.toString().padLeft(2, '0')}/'
                          '${now.month.toString().padLeft(2, '0')}/'
                          '${now.year}  '
                          '${now.hour.toString().padLeft(2, '0')}:'
                          '${now.minute.toString().padLeft(2, '0')}',
                      'amount': amount,
                    },
                  ];

                  amountController.clear();
                  noteController.clear();

                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    SnackBar(
                      content: Text(
                        '₹${amount.toStringAsFixed(0)} bonus added to wallet',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.card_giftcard),
                label: const Text(
                  'GIVE BONUS',
                ),
              ),
            ),
          
          const SizedBox(height: 24),

ValueListenableBuilder<List<Map<String, dynamic>>>(
  valueListenable: bonusHistory,
  builder: (context, bonuses, _) {
    final list =
        List<Map<String, dynamic>>.from(bonuses);

    list.sort((a, b) {
      final aTime = a['createdAt'];
      final bTime = b['createdAt'];

      if (aTime is DateTime &&
          bTime is DateTime) {
        return bTime.compareTo(aTime);
      }

      return 0;
    });

    double totalBonus = 0;

    for (final item in list) {
      totalBonus +=
          (item['amount'] as num?)?.toDouble() ?? 0;
    }

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF3E8FF),
            borderRadius:
                BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'Bonus Summary',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Total Bonus Given: ₹${totalBonus.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Users Rewarded: ${list.length}',
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        const Text(
          'Bonus History',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        if (list.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'No bonus history yet',
              ),
            ),
          )
        else
          ...list.map((item) {
            final amount =
                (item['amount'] as num?)
                        ?.toDouble() ??
                    0;
          final after =
                (item['balanceAfter'] as num?)
                        ?.toDouble() ??
                    0;

            final createdAt =
                item['createdAt'];
final txnNumber =
    (item['txnNumber'] ?? '').toString();
            String dateText = '';

            if (createdAt is DateTime) {
              dateText =
                  '${createdAt.day.toString().padLeft(2, '0')}/'
                  '${createdAt.month.toString().padLeft(2, '0')}/'
                  '${createdAt.year}  '
                  '${createdAt.hour.toString().padLeft(2, '0')}:'
                  '${createdAt.minute.toString().padLeft(2, '0')}';
            }

            return Card(
              margin:
                  const EdgeInsets.only(
                bottom: 10,
              ),
              child: Padding(
                padding:
                    const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor:
                              Colors.purple,
                          child: Icon(
                            Icons.card_giftcard,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            (item['username'] ?? '@CricNovaPlay').toString(),
                            style:
                                const TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          '+₹${amount.toStringAsFixed(0)}',
                          style:
                              const TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
if (txnNumber.isNotEmpty)
  Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Text(
      txnNumber,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.purple,
      ),
    ),
  ),
                    const SizedBox(height: 10),

                Text(
  '📝 Reason: ${(item['note'] ?? 'Admin reward bonus').toString()}',
),

                    if (dateText.isNotEmpty)
                      Text(
                        '⏰ $dateText',
                      ),

                    Text(
  'Wallet: ₹${((item['balanceBefore'] as num?)?.toDouble() ?? 0).toStringAsFixed(0)}'
  ' → ₹${((item['balanceAfter'] as num?)?.toDouble() ?? 0).toStringAsFixed(0)}',
),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  },
),
            ],
          
          
        ),
      ),
    );
  }
}



class AdminWalletPage extends StatefulWidget {
  const AdminWalletPage({super.key});

  @override
  State<AdminWalletPage> createState() =>
      _AdminWalletPageState();
}

class _AdminWalletPageState
    extends State<AdminWalletPage> {
   String selectedFilter = 'ALL';
int selectedHours = 24;
 String selectedBonusFilter = 'ALL_BONUS';
  
  Future<void> reversePayment(
  BuildContext context,
  Map<String, dynamic> item,
) async {
  final updated =
      List<Map<String, dynamic>>.from(
    walletRequests.value,
  );

  final index = updated.indexWhere((request) {
  final requestType =
      (request['type'] ?? '').toString().toUpperCase();

  final itemType =
      (item['type'] ?? '').toString().toUpperCase();

  final requestAmount =
      double.tryParse(
        (request['amount'] ?? 0).toString(),
      ) ??
      0;

  final itemAmount =
      double.tryParse(
        (item['amount'] ?? 0).toString(),
      ) ??
      0;

  return requestType == itemType &&
      requestAmount == itemAmount &&
      request['resolvedAt'] == item['resolvedAt'];
});

if (index == -1) return;

  final status =
      (updated[index]['status'] ?? '')
          .toString()
          .toUpperCase();

  if (status != 'APPROVED') return;
if (updated[index]['isReversed'] == true) return;
  final type =
      (updated[index]['type'] ?? '')
          .toString()
          .toUpperCase();

  // Reverse sirf Deposit ka hoga
  if (type != 'DEPOSIT') return;

  final amount =
      double.tryParse(
        (updated[index]['amount'] ?? 0)
            .toString(),
      ) ??
      0;
final txnNumber =
    (updated[index]['txnNumber'] ?? '')
        .toString();
  final noteController =
      TextEditingController();

  final reverseNote =
      await showDialog<String>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        scrollable: true,
        title: const Text(
          'Reverse Deposit',
        ),
        content: TextField(
          controller: noteController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Admin Note / Reason',
            hintText:
                'Deposit reverse karne ka reason likhiye',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(
                dialogContext,
              );
            },
            child: const Text(
              'CANCEL',
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final note =
                  noteController.text.trim();

              if (note.isEmpty) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Reverse reason likhna zaroori hai',
                    ),
                  ),
                );
                return;
              }

              Navigator.pop(
                dialogContext,
                note,
              );
            },
            child: const Text(
              'REVERSE',
            ),
          ),
        ],
      );
    },
  );
  noteController.dispose();

  // CANCEL kiya to kuch nahi hoga
  if (reverseNote == null) return;

  final now = DateTime.now();

  // Deposit ka paisa user wallet se minus hoga
walletBalance.value -= amount;

// Original APPROVED request ko bilkul same rehne do.
// Reverse ke liye alag nayi history entry banao.
// Original APPROVED entry ko history me rehne do,
// lekin dobara reverse hone se lock kar do.
updated[index] = {
  ...updated[index],
  'isReversed': true,
  'reversedAt': now,
  'reverseNote': reverseNote,
};

// Reverse ki alag entry
final reversedEntry = <String, dynamic>{
  ...updated[index],
  'status': 'REVERSED',
  'isReverseEntry': true,
  'reversedAt': now,
  'reverseNote': reverseNote,
};

updated.add(reversedEntry);

walletRequests.value = updated;

// Nayi REVERSED entry original APPROVED ke baad add hogi.
// My Requests me newest-first sorting ise upar dikhayegi.


walletRequests.value = updated;

  // User Transaction History
  transactionHistory.value = [
  ...transactionHistory.value,
  {
    'title': 'Deposit Reversed',
        'txnNumber': txnNumber,
    'subtitle': 'Admin: $reverseNote',
    'dateTime':
        '${now.day.toString().padLeft(2, '0')}/'
        '${now.month.toString().padLeft(2, '0')}/'
        '${now.year}  '
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}',
    'amount': -amount,
  },
];

  if (!context.mounted) return;

  ScaffoldMessenger.of(context)
      .showSnackBar(
    SnackBar(
      content: Text(
        '₹${amount.toStringAsFixed(0)} deposit reversed',
      ),
    ),
  );
}
 
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: const Text('Admin Wallet'),
  actions: [
    Padding(
  padding: const EdgeInsets.only(right: 10),
  child: SizedBox(
    height: 42,
    child: ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const WalletSummaryPage(),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor:
            const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
        elevation: 5,
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(24),
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 20,
          ),
          SizedBox(width: 7),
          Text(
            'Summary',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          SizedBox(width: 6),
          Icon(
            Icons.arrow_forward_rounded,
            size: 20,
          ),
        ],
      ),
    ),
  ),
),
  ],
),
      body: ValueListenableBuilder<
          List<Map<String, dynamic>>>(
        valueListenable: walletRequests,
        builder: (context, requests, _) {
          final approved = requests
    .where(
      (item) =>
          (item['status'] ?? '')
                  .toString()
                  .toUpperCase() ==
              'APPROVED' &&
          item['isReversed'] != true,
    )
    .map(
      (item) =>
          Map<String, dynamic>.from(item),
    )
    .toList();

for (final bonus in bonusHistory.value) {
  approved.add({
    ...bonus,
    'bonusType':
        (bonus['type'] ?? 'USER_BONUS')
            .toString()
            .toUpperCase(),
    'type': 'BONUS',
    'status': 'APPROVED',
    'resolvedAt': bonus['createdAt'],
  });
}
for (final tx in transactionHistory.value) {
  final title =
      (tx['title'] ?? '')
          .toString()
          .toUpperCase();

  if (title == 'WELCOME BONUS') {
    approved.add({
      ...tx,
      'bonusType': 'WELCOME_BONUS',
      'type': 'BONUS',
      'status': 'APPROVED',
      'resolvedAt': (() {
  final rawDate =
      tx['createdAt'] ??
      tx['dateTimeValue'] ??
      tx['date'];

  if (rawDate is DateTime) {
    return rawDate;
  }

  return DateTime.tryParse(
    rawDate?.toString() ?? '',
  );
})(),
    });
  }
}
          approved.sort((a, b) {
            final aTime = a['resolvedAt'];
            final bTime = b['resolvedAt'];

            if (aTime is DateTime &&
                bTime is DateTime) {
              return bTime.compareTo(aTime);
            }

            return 0;
          });
final cutoffTime = DateTime.now().subtract(
  Duration(hours: selectedHours),
);
          final filtered = approved.where((item) {
  final type =
      (item['type'] ?? '').toString().toUpperCase();

  if (selectedFilter == 'DEPOSIT') {
    if (type != 'DEPOSIT') return false;
  }

  if (selectedFilter == 'WITHDRAWAL') {
    if (type != 'WITHDRAW' &&
        type != 'WITHDRAWAL') {
      return false;
    }
  }
            if (selectedFilter == 'BONUS') {
  if (type != 'BONUS') return false;

  final bonusType =
      (item['bonusType'] ?? '')
          .toString()
          .toUpperCase();

  if (selectedBonusFilter == 'WELCOME_BONUS' &&
      bonusType != 'WELCOME_BONUS') {
    return false;
  }

  if (selectedBonusFilter == 'USER_BONUS' &&
      bonusType != 'USER_BONUS') {
    return false;
  }
}

  final rawResolvedAt = item['resolvedAt'];

DateTime? resolvedAt;

if (rawResolvedAt is DateTime) {
  resolvedAt = rawResolvedAt;
} else if (rawResolvedAt is String) {
  resolvedAt = DateTime.tryParse(rawResolvedAt);
}

if (resolvedAt == null) {
  return false;
}

  final age =
      DateTime.now().difference(resolvedAt);

  if (age.isNegative) {
    return false;
  }

  return age.inMinutes <= selectedHours * 60;
}).toList();

          double totalAmount = 0;

          for (final item in filtered) {
            totalAmount +=
                double.tryParse(
                      (item['amount'] ?? 0)
                          .toString(),
                    ) ??
                    0;
          }
double depositTotal = 0;
double withdrawalTotal = 0;
int depositCount = 0;
int withdrawalCount = 0;
double bonusTotal = 0;
int bonusCount = 0;

double welcomeBonusTotal = 0;
int welcomeBonusCount = 0;

double userRewardBonusTotal = 0;
int userRewardBonusCount = 0;
for (final item in filtered) {
  final type =
      (item['type'] ?? '').toString().toUpperCase();

  final amount =
      double.tryParse(
        (item['amount'] ?? 0).toString(),
      ) ??
      0;

  if (type == 'DEPOSIT') {
  depositTotal += amount;
  depositCount++;
} else if (
    type == 'WITHDRAW' ||
    type == 'WITHDRAWAL') {
  withdrawalTotal += amount;
  withdrawalCount++;
} else if (type == 'BONUS') {
  bonusTotal += amount;
  bonusCount++;

  final bonusType =
      (item['bonusType'] ?? '')
          .toString()
          .toUpperCase();

  if (bonusType == 'WELCOME_BONUS') {
    welcomeBonusTotal += amount;
    welcomeBonusCount++;
  } else if (bonusType == 'USER_BONUS') {
    userRewardBonusTotal += amount;
    userRewardBonusCount++;
  }
}
}
          

            Widget filterButton(
  String text,
  String value,
) {
  final selected = selectedFilter == value;

  return Padding(
    padding: const EdgeInsets.only(right: 8),
    child: SizedBox(
      width: 125,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            selectedFilter = value;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor:
              selected ? Colors.pink : Colors.white,
          foregroundColor:
              selected ? Colors.white : Colors.black87,
          elevation: selected ? 2 : 0,
          side: BorderSide(
            color: selected
                ? Colors.pink
                : Colors.grey.shade300,
          ),
        ),
        child: Text(text),
      ),
    ),
  );
}

Widget bonusFilterButton(
  String text,
  String value,
) {
  final selected =
      selectedBonusFilter == value;

  return Padding(
    padding: const EdgeInsets.only(right: 8),
    child: ElevatedButton(
      onPressed: () {
        setState(() {
          selectedBonusFilter = value;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor:
            selected
                ? Colors.purple
                : Colors.white,
        foregroundColor:
            selected
                ? Colors.white
                : Colors.black87,
        elevation: selected ? 2 : 0,
        side: BorderSide(
          color: selected
              ? Colors.purple
              : Colors.grey.shade300,
        ),
      ),
      child: Text(text),
    ),
  );
}
      
             return ListView(
            padding:
                const EdgeInsets.all(16),
            children: [
              Container(
                padding:
                    const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(
                    0xFFFFF1F4,
                  ),
                  borderRadius:
                      BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Approved Wallet Activity',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Total Amount: ₹${totalAmount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Transactions: ${filtered.length}',
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

       Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
  mainAxisSize: MainAxisSize.min,
  mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Colors.green.shade100,
              child: const Icon(
                Icons.arrow_downward,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Deposits',
              style: TextStyle(fontSize: 15),
            ),
            Text(
              '₹${depositTotal.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            Text(
              '$depositCount Transactions',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    ),

    const SizedBox(width: 8),

    Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
  mainAxisSize: MainAxisSize.min,
  mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Colors.red.shade100,
              child: const Icon(
                Icons.arrow_upward,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Withdrawals',
              style: TextStyle(fontSize: 15),
            ),
            Text(
              '₹${withdrawalTotal.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            Text(
              '$withdrawalCount Transactions',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    ),

    const SizedBox(width: 8),
          Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.purple.shade50,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.purple.shade100,
                  child: const Icon(
                    Icons.card_giftcard,
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bonus',
                        style: TextStyle(fontSize: 15),
                      ),
                      Text(
                        '₹${bonusTotal.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 5), 
            Text(
              '$bonusCount Transactions',
              style: const TextStyle(fontSize: 11),
            ),

            const Divider(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Welcome Bonus',
                    style: TextStyle(fontSize: 11),
                  ),
                ),
                Text(
                  '₹${welcomeBonusTotal.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 3),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'User Reward',
                    style: TextStyle(fontSize: 11),
                  ),
                ),
                Text(
                  '₹${userRewardBonusTotal.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  ],
),
                         

const SizedBox(height: 10), 
              
              const SizedBox(height: 18),

              SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Row(
    children: [
      filterButton(
        'All',
        'ALL',
      ),
      filterButton(
        'Deposit',
        'DEPOSIT',
      ),
      filterButton(
        'Withdrawal',
        'WITHDRAWAL',
      ),
      filterButton(
        'Bonus',
        'BONUS',
      ),
    ],
  ),
),
   if (selectedFilter == 'BONUS') ...[
  const SizedBox(height: 10),

  SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: [
        bonusFilterButton(
          'All Bonus',
          'ALL_BONUS',
        ),
        bonusFilterButton(
          'Welcome Bonus',
          'WELCOME_BONUS',
        ),
        bonusFilterButton(
          'User Reward',
          'USER_BONUS',
        ),
      ],
    ),
  ),
],           
              
const SizedBox(height: 10),

SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Row(
    children: [12, 24, 48, 72, 96, 120, 144].map((hours) {
final selected = selectedHours == hours;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text('${hours}h'),
          selected: selected,
          showCheckmark: false,
          selectedColor: Colors.pink,
          backgroundColor: Colors.white,
          labelStyle: TextStyle(
            color: selected
                ? Colors.white
                : Colors.black87,
          ),
          onSelected: (_) {
            setState(() {
              selectedHours = hours;
            });
          },
        ),
      );
    }).toList(),
  ),
),
              const SizedBox(height: 18),

              if (filtered.isEmpty)
                const Padding(
                  padding:
                      EdgeInsets.only(top: 80),
                  child: Center(
                    child: Text(
                      'No approved wallet transactions',
                      style: TextStyle(
                        fontSize: 17,
                      ),
                    ),
                  ),
                )
              else        
               ...filtered.map((item) {
                  final type =
                      (item['type'] ?? '')
                          .toString()
                          .toUpperCase();

                  final amount =
                      double.tryParse(
                            (item['amount'] ?? 0)
                                .toString(),
                          ) ??
                          0;

                  final isDeposit =
                      type == 'DEPOSIT';

                  return Card(
                    margin:
                        const EdgeInsets.only(
                      bottom: 12,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            isDeposit
                                ? Colors.green
                                    .shade50
                                : Colors.red
                                    .shade50,
                        child: Icon(
                          isDeposit
                              ? Icons
                                  .arrow_downward
                              : Icons
                                  .arrow_upward,
                          color: isDeposit
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                      title: Text(
  type == 'DEPOSIT'
      ? 'Deposit'
      : type == 'WITHDRAWAL'
          ? 'Withdrawal'
          : type == 'BONUS'
              ? ((item['bonusType'] ?? '').toString().toUpperCase() ==
                      'WELCOME_BONUS'
                  ? 'Welcome Bonus 🎁'
                  : (item['bonusType'] ?? '').toString().toUpperCase() ==
                          'USER_BONUS'
                      ? 'User Reward Bonus 🎁'
                      : 'Bonus 🎁')
              : type,
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    const Text('APPROVED'),
    const SizedBox(height: 4),
    if (item['resolvedAt'] is DateTime)
      Text(
        'Approved: '
        '${(item['resolvedAt'] as DateTime).day.toString().padLeft(2, '0')}/'
        '${(item['resolvedAt'] as DateTime).month.toString().padLeft(2, '0')}/'
        '${(item['resolvedAt'] as DateTime).year}  '
        '${(item['resolvedAt'] as DateTime).hour.toString().padLeft(2, '0')}:'
        '${(item['resolvedAt'] as DateTime).minute.toString().padLeft(2, '0')}',
        style: const TextStyle(
          fontSize: 13,
        ),
      ),
  ],
),
                      trailing: Column(
  mainAxisSize: MainAxisSize.min,
  crossAxisAlignment: CrossAxisAlignment.end,
  children: [
    Text(
      '₹${amount.toStringAsFixed(0)}',
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
    
    
    if (isDeposit)
  TextButton(
    style: TextButton.styleFrom(
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    ),
    onPressed: () {
      reversePayment(
        context,
        item,
      );
    },
    child: const Text(
      '◀ REVERSE',
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: Colors.red,
      ),
    ),
  ),
  ],
),
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}     
                    
class WalletSummaryPage extends StatefulWidget {
  const WalletSummaryPage({super.key});

  @override
  State<WalletSummaryPage> createState() =>
      _WalletSummaryPageState();
}

class _WalletSummaryPageState extends State<WalletSummaryPage> {
  int selectedDays = 30;

  DateTime? _readDate(dynamic value) {
    if (value is DateTime) return value;

    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }

  bool _insideSelectedDays(DateTime? date) {
    if (date == null) return false;

    if (selectedDays == 0) {
      final now = DateTime.now();

      return date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
    }

    final cutoff = DateTime.now().subtract(
      Duration(days: selectedDays),
    );

    return !date.isBefore(cutoff);
  }

  double _amount(dynamic value) {
    return double.tryParse(
          (value ?? 0).toString(),
        ) ??
        0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Wallet Summary',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: ValueListenableBuilder<double>(
        valueListenable: walletBalance,
        builder: (context, userWallet, _) {
          return ValueListenableBuilder<
              List<Map<String, dynamic>>>(
            valueListenable: transactionHistory,
            builder: (context, history, _) {
              double contestEntry = 0;
              double winning = 0;

              for (final item in history) {
                final title =
                    (item['title'] ?? '')
                        .toString()
                        .toUpperCase();

                final type =
                    (item['type'] ?? '')
                        .toString()
                        .toUpperCase();

                DateTime? date =
                    _readDate(item['createdAt']) ??
                    _readDate(item['resolvedAt']) ??
                    _readDate(item['date']);

                // Agar DateTime alag field me save hai.
                date ??= _readDate(
                  item['dateTimeValue'],
                );
// Purani history me proper DateTime nahi hai
                // to use include rakhenge.
                final include =
                    date == null ||
                    _insideSelectedDays(date);

                if (!include) continue;

                final amount =
                    _amount(item['amount']).abs();

                final isEntry =
                    type == 'ENTRY' ||
                    type == 'CONTEST_ENTRY' ||
                    title.contains('CONTEST ENTRY') ||
                    title.contains('ENTRY FEE');

                final isWinning =
                    type == 'WINNING' ||
                    type == 'WIN' ||
                    title.contains('WINNING') ||
                    title.contains('WINNINGS');

                if (isEntry) {
                  contestEntry += amount;
                }

                if (isWinning) {
                  winning += amount;
                }
              }

              final adminEarning =
                  contestEntry - winning;

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // =========================
                  // DAYS FILTER
                  // =========================
                  Card(
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_month,
                            size: 28,
                          ),
                          const SizedBox(width: 10),

                          const Expanded(
                            child: Text(
                              'Select Days:',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),

                          DropdownButton<int>(
                            value: selectedDays,
                            underline:
                                const SizedBox(),
                            items: const [
                              DropdownMenuItem(
                                value: 0,
                                child: Text(
                                  '0 Days',
                                ),
                              ),
                              DropdownMenuItem(
value: 1,
                                child: Text(
                                  '1 Day',
                                ),
                              ),
                              DropdownMenuItem(
                                value: 7,
                                child: Text(
                                  '7 Days',
                                ),
                              ),
                              DropdownMenuItem(
                                value: 15,
                                child: Text(
                                  '15 Days',
                                ),
                              ),
                              DropdownMenuItem(
                                value: 30,
                                child: Text(
                                  '30 Days',
                                ),
                              ),
                              DropdownMenuItem(
                                value: 60,
                                child: Text(
                                  '60 Days',
                                ),
                              ),
                              DropdownMenuItem(
                                value: 90,
                                child: Text(
                                  '90 Days',
                                ),
                              ),
                              DropdownMenuItem(
                                value: 180,
                                child: Text(
                                  '180 Days',
                                ),
                              ),
                              DropdownMenuItem(
                                value: 365,
                                child: Text(
                                  '365 Days',
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              if (value == null) {
                                return;
                              }

                              setState(() {
                                selectedDays = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // =========================
                  // MAIN SUMMARY CARD
                  // =========================
Card(
                    child: Padding(
                      padding:
                          const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .center,
                            children: [
                              Icon(
                                Icons
                                    .account_balance_wallet,
                                size: 34,
                                color:
                                    Colors.brown,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'WALLET SUMMARY',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                         Column(
  children: [
    SizedBox(
      width: 135,
      child: _summaryBox(
        title: 'User Wallet',
        amount: userWallet,
        icon: Icons.people,
        color: Colors.blue,
      ),
    ),

    const SizedBox(height: 14),

    Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: _summaryBox(
            title: 'Contest Entry',
            amount: contestEntry,
            icon: Icons.confirmation_number,
            color: Colors.red,
          ),
        ),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            '-',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        Expanded(
          child: _summaryBox(
            title: 'Winning',
            amount: winning,
            icon: Icons.emoji_events,
            color: Colors.green,
          ),
        ),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            '=',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        Expanded(
          child: _summaryBox(
            title: 'Admin Earning',
            amount: adminEarning,
            icon: Icons.monetization_on,
            color: Colors.deepPurple,
          ),
        ),
      ],
    ),
  ],
),

                          const SizedBox(height: 20),

                          SizedBox(
                            width: 210,
                            child:
                                ElevatedButton.icon(
                              style:
                                  ElevatedButton
                                      .styleFrom(
                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  vertical: 14,
                                ),
                              ),
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled:
                                      true,
                                  builder:
                                      (context) {
                                    return Padding(
                                      padding:
                                          const EdgeInsets
                                              .all(
                                        20,
                                      ),
                                      child: Column(
                                        mainAxisSize:
                                            MainAxisSize
                                                .min,
                                        children: [
                                          const Text(
                                            'Wallet Summary Detail',
                                            style:
                                                TextStyle(
                                              fontSize:
                                                  20,
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                            ),
                                          ),

                                          const SizedBox(
                                            height: 18,
                                          ),

                                          _detailRow(
                                            'Users Wallet Balance',
userWallet,
                                            Colors.blue,
                                          ),

                                          _detailRow(
                                            'Total Contest Entry',
                                            contestEntry,
                                            Colors.red,
                                          ),

                                          _detailRow(
                                            'Total Winning',
                                            winning,
                                            Colors.green,
                                          ),

                                          _detailRow(
                                            'Admin Earning',
                                            adminEarning,
                                            Colors
                                                .deepPurple,
                                          ),

                                          const SizedBox(
                                            height: 12,
                                          ),

                                          Text(
                                            selectedDays ==
                                                    0
                                                ? 'Showing today\'s data'
                                                : 'Showing last $selectedDays days data',
                                            style:
                                                const TextStyle(
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                            ),
                                          ),

                                          const SizedBox(
                                            height: 10,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                           icon: const Icon(
                                Icons
                                    .receipt_long,
                              ),
                              label: const Text(
                                'IN DETAIL  ›',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // =========================
                  // DETAIL CARDS
                  // =========================
                  Row(
                    children: [
                      Expanded(
                        child: _bigCard(
                          title:
                              'Users Wallet Balance',
                          amount: userWallet,
                          subtitle:
                              'Total balance in all users wallets (current)',
                          icon: Icons.people,
                          color: Colors.blue,
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: _bigCard(
                          title:
                              'Total Contest Entry',
                          amount:
                              contestEntry,
                          subtitle:
                              'Total contest entry collected (selected days)',
                          icon: Icons
                              .confirmation_number,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: _bigCard(
                          title:
                              'Total Winning',
                          amount: winning,
                          subtitle:
                              'Total winning given to users (selected days)',
                          icon: Icons
                              .emoji_events,
                          color: Colors.green,
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: _bigCard(
                          title:
                              'Admin Earning',
                          amount:
                              adminEarning,
                          subtitle:
                              'Contest Entry − Winning (selected days)',
                          icon: Icons
                              .monetization_on,
                          color: Colors
                              .deepPurple,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),                 
              // =========================
                  // FORMULA
                  // =========================
                  Card(
                    child: Padding(
                      padding:
                          const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          const Icon(
                            Icons.info,
                            color: Colors.blue,
                            size: 30,
                          ),

                          const SizedBox(
                            width: 12,
                          ),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                const Text(
                                  'Calculation Formula',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),

                                const SizedBox(
                                  height: 6,
                                ),

                                const Text(
                                  'Admin Earning = Contest Entry − Winning',
                                  style: TextStyle(
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),

                                const SizedBox(
                                  height: 4,
                                ),

                                Text(
                                  selectedDays ==
                                          0
                                      ? 'Contest Entry and Winning show today\'s data.'
                                      : 'Contest Entry and Winning show last $selectedDays days data.',
                                ),

                                const SizedBox(
                                  height: 4,
                                ),

                                const Text(
                                  'User Wallet Balance shows the current wallet balance.',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }                              
     Widget _summaryBox({
    required String title,
    required double amount,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: 0.10,
        ),
        borderRadius:
            BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 7),

          Icon(
            icon,
            color: color,
            size: 25,
          ),

          const SizedBox(height: 7),

          Text(
            '₹${amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }                                       
     Widget _bigCard({
    required String title,
    required double amount,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 30,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style:
                        const TextStyle(
                      fontSize: 14,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              '₹${amount.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }                                       
Widget _detailRow(
    String title,
    double amount,
    Color color,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 7,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}





    class PaymentScreenshotPage extends StatelessWidget {
final String screenshot;
       

  const PaymentScreenshotPage({
    super.key,
    required this.screenshot,
  });

  @override
  Widget build(BuildContext context) {
    final cleanImage = screenshot.contains(',')
        ? screenshot.split(',').last
        : screenshot;

    final imageBytes = base64Decode(cleanImage);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Payment Screenshot'),
      ),
      
   body: LayoutBuilder(
  builder: (context, constraints) {
    return ClipRect(
      child: InteractiveViewer(
        constrained: false,
        minScale: 1.0,
        maxScale: 5.0,
        panEnabled: true,
        scaleEnabled: true,
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: constraints.maxWidth,
          child: Image.memory(
            imageBytes,
            fit: BoxFit.fitWidth,
          ),
        ),
      ),
    );
  },
),
    );
  }
}   
      
      
class AdminDepositSettingsPage extends StatefulWidget {
  const AdminDepositSettingsPage({super.key});

  @override
  State<AdminDepositSettingsPage> createState() =>
      _AdminDepositSettingsPageState();
}

class _AdminDepositSettingsPageState
    extends State<AdminDepositSettingsPage> {

  late final TextEditingController paymentController;
  late final TextEditingController warningController;

  @override
  void initState() {
    super.initState();

    paymentController = TextEditingController(
      text: depositPaymentText.value,
    );

    warningController = TextEditingController(
      text: depositWarningText.value,
    );
  }

  @override
  void dispose() {
    paymentController.dispose();
    warningController.dispose();
    super.dispose();
  }
    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deposit Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Payment Image / QR',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          ValueListenableBuilder<String?>(
            valueListenable: depositPaymentImage,
            builder: (context, image, _) {
              return Container(
                height: 180,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: image == null
    ? const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 60,
          ),
          SizedBox(height: 8),
          Text('No payment image set'),
        ],
      )
    : Image.network(
        image,
        fit: BoxFit.contain,
      ),
              );
            },
          ),

          const SizedBox(height: 10),

          ElevatedButton.icon(
            onPressed: () {
  pickImageFromGallery(
    depositPaymentImage,
  );
},
            icon: const Icon(Icons.photo_library),
            label: const Text('SET PAYMENT IMAGE'),
          ),

          const SizedBox(height: 20),

          TextField(
            controller: paymentController,
            decoration: const InputDecoration(
              labelText: 'Copy Payment Line / UPI ID',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 16),

          TextField(
            controller: warningController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Payment Warning Line',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: () {
              depositPaymentText.value =
                  paymentController.text.trim();

              depositWarningText.value =
                  warningController.text.trim();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Deposit settings saved',
                  ),
                ),
              );
            },
            child: const Text('SAVE SETTINGS'),
          ),
        ],
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ValueListenableBuilder<bool>(
          valueListenable: hindiMode,
          builder: (context, isHindi, _) {
            return Text(isHindi ? 'सेटिंग्स' : 'Settings');
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ValueListenableBuilder<bool>(
              valueListenable: darkMode,
              builder: (context, isDark, _) {
                return SwitchListTile(
                  secondary: const Icon(Icons.dark_mode_outlined),
                  title: Text(hindiMode.value ? 'डार्क मोड' : 'Dark Mode'),
                  subtitle: Text(
                    hindiMode.value
                        ? (isDark ? 'डार्क मोड चालू' : 'डार्क मोड बंद')
                        : (isDark ? 'Dark mode on' : 'Dark mode off'),
                  ),
                  value: isDark,
                  onChanged: (value) {
                    darkMode.value = value;
                  },
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.notifications_outlined),
              title: const Text('Notifications'),
              subtitle: const Text('Manage notification preferences'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ),
          Card(
            child: ValueListenableBuilder<bool>(
              valueListenable: hindiMode,
              builder: (context, isHindi, _) {
                return SwitchListTile(
                  secondary: const Icon(Icons.language),
                  title: const Text('Language'),
                  subtitle: Text(isHindi ? 'हिंदी' : 'English'),
                  value: isHindi,
                  onChanged: (value) {
                    hindiMode.value = value;
                  },
                );
              },
            ),
          ),
        ], 
      ),
    );
  }
}

class AdminMatchesPage extends StatefulWidget {
  const AdminMatchesPage({super.key});

  @override
  State<AdminMatchesPage> createState() => _AdminMatchesPageState();
}

class _AdminMatchesPageState extends State<AdminMatchesPage> {
  Timer? adminMatchStatusTimer;
  String _shortTeamName(String name) {
  final words = name.trim().split(RegExp(r'\s+'));

  if (words.length == 1) {
    return words.first.length <= 3
        ? words.first.toUpperCase()
        : words.first.substring(0, 3).toUpperCase();
  }

  return words
      .map((word) => word.isNotEmpty ? word[0].toUpperCase() : '')
      .join();
}
 void _refreshMatches() {
  if (!mounted) return;
  setState(() {});
}

@override
void initState() {
  super.initState();
  adminMatches.addListener(_refreshMatches);
  adminMatchStatusTimer = Timer.periodic(
  const Duration(seconds: 1),
  (_) => _updateAutomaticMatchStatus(),
);
}

@override
void dispose() {
  adminMatches.removeListener(_refreshMatches);
  adminMatchStatusTimer?.cancel();
  super.dispose();
}
  void _updateAutomaticMatchStatus() {
  final now = DateTime.now();
  bool changed = false;

  final updated = adminMatches.value.map((match) {
    final startTime = _parseMatchDateTime(
      match['date'] ?? '',
      match['time'] ?? '',
    );

    if (startTime == null) return match;

    final durationMinutes =
    int.tryParse(match['durationMinutes'] ?? '180') ?? 180;

final endTime = startTime.add(
  Duration(minutes: durationMinutes),
);

    String newStatus;

    if (now.isBefore(startTime)) {
      newStatus = 'UPCOMING';
    } else if (now.isBefore(endTime)) {
      newStatus = 'LIVE';
    } else {
      newStatus = 'COMPLETED';
    }

    if (match['status'] != newStatus) {
      changed = true;

      return <String, String>{
        ...match,
        'status': newStatus,
      };
    }

    return match;
  }).toList();

  if (changed) {
  adminMatches.value = updated;

  final syncedJoinedMatches =
      joinedMatches.value.map((joined) {
    final adminList = updated.where(
      (admin) =>
          admin['team1'] == joined.team1 &&
          admin['team2'] == joined.team2,
    ).toList();

    if (adminList.isEmpty) return joined;

    final admin = adminList.first;

    final newStartTime = _parseMatchDateTime(
      admin['date'] ?? '',
      admin['time'] ?? '',
    );

    final durationMinutes =
        int.tryParse(
          admin['durationMinutes']?.toString() ?? '180',
        ) ??
        180;

    return MatchModel(
      team1: joined.team1,
      team2: joined.team2,
      team1Flag: joined.team1Flag,
      team2Flag: joined.team2Flag,
      title: admin['title'] ?? joined.title,
      time: (admin['date'] ?? '').trim().isNotEmpty &&
        (admin['time'] ?? '').trim().isNotEmpty
    ? '${admin['date']!.trim()} • ${admin['time']!.trim()}'
    : joined.time,
      status: admin['status'] ?? joined.status,
      userPoints: joined.userPoints,
      startTime: newStartTime ?? joined.startTime,
      liveDuration: Duration(minutes: durationMinutes),
      winner: joined.winner,
      team1Score: joined.team1Score,
      team2Score: joined.team2Score,
      userRank: joined.userRank,
      entryFee: joined.entryFee,
      prizePool: joined.prizePool,
      contestName: joined.contestName,
      contestSpots: joined.contestSpots,
      team1Players: joined.team1Players,
      team2Players: joined.team2Players,
    );
  }).toList();
    
// ===== SYNC TEAM / STATS KEYS AFTER ADMIN TIME EDIT =====
for (final oldJoined in joinedMatches.value) {
  final matches = updated.where(
    (admin) =>
        admin['team1'] == oldJoined.team1 &&
        admin['team2'] == oldJoined.team2,
  );

  if (matches.isEmpty) continue;

  final admin = matches.first;
for (final contest in createdContests) {
  if (contest['team1'] == oldJoined.team1 &&
      contest['team2'] == oldJoined.team2) {
    contest['match'] = Map<String, dynamic>.from(admin);
    contest['team1'] = admin['team1'];
    contest['team2'] = admin['team2'];
  }
}
  final oldParts = oldJoined.time.split('•');

  final oldDate =
      oldParts.isNotEmpty ? oldParts[0].trim() : '';

  final oldTime =
      oldParts.length > 1 ? oldParts[1].trim() : '';

  final newDate = (admin['date'] ?? '').trim();
  final newTime = (admin['time'] ?? '').trim();

  if (newDate.isEmpty || newTime.isEmpty) continue;

  final oldKey =
      '${oldJoined.team1}_${oldJoined.team2}_${oldDate}_$oldTime';

  final newKey =
      '${oldJoined.team1}_${oldJoined.team2}_${newDate}_$newTime';

  if (oldKey == newKey) continue;

  // Draft / created team key
  final drafts =
      Map<String, Map<String, dynamic>>.from(draftTeams.value);

  if (drafts.containsKey(oldKey)) {
    drafts[newKey] = drafts[oldKey]!;
    drafts.remove(oldKey);
    draftTeams.value = drafts;
  }

  // Saved team match keys
  for (int i = 0; i < savedTeamMatchKeys.length; i++) {
    if (savedTeamMatchKeys[i] == oldKey) {
      savedTeamMatchKeys[i] = newKey;
    }
  }

  // Player stats key
  if (savedPlayerStats.containsKey(oldKey)) {
    savedPlayerStats[newKey] = savedPlayerStats[oldKey]!;
    savedPlayerStats.remove(oldKey);
  }

  // Joined contest match key
  final contests =
      List<Map<String, dynamic>>.from(joinedContests.value);

  bool contestChanged = false;

  for (final contest in contests) {
    if (contest['matchKey'] == oldKey) {
      contest['matchKey'] = newKey;
      contestChanged = true;
    }
  }

  if (contestChanged) {
    joinedContests.value = contests;
  }
}
  joinedMatches.value = syncedJoinedMatches;
}
}
  DateTime? _parseMatchDateTime(String date, String time) {
  try {
    final months = {
      'jan': 1,
      'feb': 2,
      'mar': 3,
      'apr': 4,
      'may': 5,
      'jun': 6,
      'jul': 7,
      'aug': 8,
      'sep': 9,
      'oct': 10,
      'nov': 11,
      'dec': 12,
    };

    int day;
int month;
int year;

if (date.contains('/')) {
  final dateParts = date.trim().split('/');
  if (dateParts.length != 3) return null;

  day = int.parse(dateParts[0]);
  month = int.parse(dateParts[1]);
  year = int.parse(dateParts[2]);
} else {
  final dateParts = date.trim().toLowerCase().split(' ');
  if (dateParts.length < 3) return null;

  day = int.parse(dateParts[0]);

  final parsedMonth = months[dateParts[1]];
  if (parsedMonth == null) return null;

  month = parsedMonth;
  year = int.parse(dateParts[2]);
}

    final timeText = time.trim().toUpperCase();
    final isPM = timeText.contains('PM');
    final isAM = timeText.contains('AM');

    final cleanTime = timeText
        .replaceAll('AM', '')
        .replaceAll('PM', '')
        .trim();

    final timeParts = cleanTime.split(':');

    int hour = int.parse(timeParts[0]);
    final minute =
        timeParts.length > 1 ? int.parse(timeParts[1]) : 0;

    if (isPM && hour != 12) hour += 12;
    if (isAM && hour == 12) hour = 0;

    return DateTime(year, month, day, hour, minute);
  } catch (_) {
    return null;
  }
}
String _flagForTeam(String team) {
  switch (team.trim().toUpperCase()) {
    case 'IND':
    case 'INDIA':
      return '🇮🇳';

    case 'ENG':
    case 'ENGLAND':
      return '🏴';

    case 'AUS':
    case 'AUSTRALIA':
      return '🇦🇺';

    case 'SA':
    case 'SOUTH AFRICA':
      return '🇿🇦';

    case 'NZ':
    case 'NEW ZEALAND':
      return '🇳🇿';

    case 'PAK':
    case 'PAKISTAN':
      return '🇵🇰';

    case 'SL':
    case 'SRI LANKA':
      return '🇱🇰';

    case 'BAN':
    case 'BANGLADESH':
      return '🇧🇩';

    case 'WI':
    case 'WEST INDIES':
      return '🌴';

    default:
      return '🏏';
  }
}
  
  void _createMatch() {
  final team1Controller = TextEditingController();
  final team2Controller = TextEditingController();
  final team1LogoController = TextEditingController();
  final team2LogoController = TextEditingController();
  final team1PlayersController = TextEditingController();
  final team2PlayersController = TextEditingController();
  final dateController = TextEditingController();
  final timeController = TextEditingController();
  final durationController = TextEditingController(text: '180');
  final matchFormatController = TextEditingController(text: 'T20');

  const p = Color(0xFFD4145A);
  const pd = Color(0xFFA80B43);
  const bg = Color(0xFFFFFAFA);
  const soft = Color(0xFFFFE7EC);
  const brd = Color(0xFFC9B9BE);
  const txt = Color(0xFF211A1D);
  const sub = Color(0xFF827479);

  showDialog(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (dialogStateContext, setDialogState) {
          BoxDecoration cardBox() => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(14),
  border: Border.all(color: brd),
);

          Widget iconTile(IconData icon, {double size = 27}) => Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: soft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: pd, size: size),
              );

          Widget section(IconData icon, String title) => Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 12),
                child: Row(
                  children: [
                    Icon(icon, color: pd, size: 29),
                    const SizedBox(width: 9),
                    Text(
                      title,
                      style: const TextStyle(
                        color: pd,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Divider(color: Color(0xFFDFA7B9)),
                    ),
                  ],
                ),
              );
  Widget pair(Widget a, Widget b) => LayoutBuilder(
                builder: (_, c) {
                  if (c.maxWidth < 250) {
                    return Column(
                      children: [
                        a,
                        const SizedBox(height: 12),
                        b,
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: a),
                      const SizedBox(width: 14),
                      Expanded(child: b),
                    ],
                  );
                },
              );

          Widget teamField(
  TextEditingController controller,
  String title,
  String hint,
) =>
    Container(
      padding: const EdgeInsets.all(12),
      decoration: cardBox(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: soft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.flag_rounded,
                  color: pd,
                  size: 21,
                ),
              ),
              const SizedBox(width: 9),
              Text(
                title,
                style: const TextStyle(
                  color: txt,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          TextField(
            controller: controller,
            minLines: 1,
            maxLines: 2,
            style: const TextStyle(
              color: txt,
              fontSize: 13.5,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: sub,
                fontSize: 12.5,
              ),
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    );
                     
  Future<void> editText(
   
            TextEditingController controller,
            String title,
            String hint, {
            int maxLines = 1,
          }) async {
            FocusManager.instance.primaryFocus?.unfocus();

await Future.delayed(
  const Duration(milliseconds: 100),
);

final oldText = controller.text;

final temp = TextEditingController.fromValue(
  TextEditingValue(
    text: oldText,
    selection: TextSelection.collapsed(
      offset: oldText.length,
    ),
    composing: TextRange.empty,
  ),
);

await showDialog(
  context: dialogStateContext,
  builder: (c) {
    final mq = MediaQuery.of(c);
    final maxH =
        mq.size.height - mq.viewInsets.bottom - 24;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: maxH,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            24,
            20,
            24,
            16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: temp,
                autofocus: false,
                minLines: maxLines == 1 ? 1 : 5,
                maxLines: maxLines,
                decoration: InputDecoration(
                  hintText: hint,
                  border: OutlineInputBorder(
                   borderRadius:
                        BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () =>
                        Navigator.pop(c),
                    child: const Text('CANCEL'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor: p,
                      foregroundColor:
                          Colors.white,
                    ),
                    onPressed: () {
  final newText = temp.text;

  FocusScope.of(c).unfocus();

  Navigator.pop(c);

  Future.delayed(
    const Duration(milliseconds: 150),
    () {
      controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset: newText.length,
        ),
        composing: TextRange.empty,
      );

      setDialogState(() {});
    },
  );
},
                    child: const Text('SAVE'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  },
);
          }
          
  
                
             Widget logoButton(
  IconData icon,
  String title,
  String subtitle,
  VoidCallback onTap,
) =>
    InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 2,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF0F3),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFFF0C8D3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: pd,
              size: 18,
            ),
            const SizedBox(width: 3),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      title,
                      maxLines: 1,
                      style: const TextStyle(
                        color: txt,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      subtitle,
                      maxLines: 1,
                      style: const TextStyle(
                        color: sub,
                        fontSize: 9.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );     
          
          
          Widget logoCard(
          
            TextEditingController controller,
            String team,
          ) {
            final logo = controller.text.trim();

            return Container(
              padding: const EdgeInsets.symmetric(
  horizontal: 12,
  vertical: 7,
),
              decoration: cardBox(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$team Logo / Flag',
                    style: const TextStyle(
                      color: txt,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Text(
                    'Use emoji or upload custom logo',
                    style: TextStyle(
                      color: sub,
                      fontSize: 12.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: logoButton(
                          Icons.emoji_emotions_outlined,
                          'Emoji Flag',
                          logo.isEmpty
                              ? 'Type / Select'
                              : logo,
                          () => editText(
                            controller,
                            '$team Logo / Flag',
                            'Example: 🇮🇳 or CSK',
                          ),
                        ),
                      ),
                      
                    ],
                  ),
                ],
              ),
            );
          }
          Widget playersCard(
            TextEditingController controller,
            String team,
          ) {
            final count = controller.text
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .length;

            return InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => editText(
                controller,
                '$team Players',
                'Player 1, Player 2, Player 3...',
                maxLines: 8,
              ),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: cardBox(),
                child: Row(
                  children: [
                    iconTile(
                      Icons.groups_rounded,
                      size: 30,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$team Players',
                            style: const TextStyle(
                              color: txt,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            count == 0
                                ? 'Add $team Players'
                                : '$count players added',
                            style: const TextStyle(
                              color: sub,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 30,
                      color: Color(0xFF3C3135),
                    ),
                  ],
                ),
              ),
            );
          }
  Widget textDetailCard(
            IconData icon,
            String title,
            TextEditingController controller, {
            TextInputType? keyboardType,
            bool upperCase = false,
            bool arrow = false,
          }) =>
              Container(
                padding: const EdgeInsets.all(12),
                decoration: cardBox(),
                child: Row(
                  children: [
                    iconTile(icon),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: txt,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextField(
                            controller: controller,
                            keyboardType: keyboardType,
                            textCapitalization: upperCase
                                ? TextCapitalization.characters
                                : TextCapitalization.none,
                            style: const TextStyle(
                              color: txt,
                              fontSize: 15,
                            ),
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                              border: InputBorder.none,
                              suffixIcon: arrow
                                  ? const Icon(
                                      Icons
                                          .keyboard_arrow_down_rounded,
                                      color:
                                          Color(0xFF4F4448),
                                    )
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
  Future<void> pickDate() async {
            final d = await showDatePicker(
              context: dialogStateContext,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(2035),
            );

            if (d != null) {
              dateController.text =
                  '${d.day.toString().padLeft(2, '0')}/'
                  '${d.month.toString().padLeft(2, '0')}/'
                  '${d.year}';

              setDialogState(() {});
            }
          }

          Future<void> pickTime() async {
            final t = await showTimePicker(
              context: dialogStateContext,
              initialTime: TimeOfDay.now(),
            );

            if (t != null) {
              final h = t.hourOfPeriod == 0
                  ? 12
                  : t.hourOfPeriod;

              final m =
                  t.minute.toString().padLeft(2, '0');

              final ap = t.period == DayPeriod.am
                  ? 'AM'
                  : 'PM';

              timeController.text = '$h:$m $ap';

              setDialogState(() {});
            }
          }

          Widget pickerCard(
            String title,
            String empty,
            String value,
            IconData icon,
            VoidCallback onTap,
          ) =>
              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: onTap,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: cardBox(),
                  child: Row(
                    children: [
                      iconTile(icon),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                color: txt,
                                fontSize: 16,
                                fontWeight:
                                    FontWeight.w700,
                              ),
                            ),
                            Text(
                              value.isEmpty
                                  ? empty
                                  : value,
                              maxLines: 1,
                              overflow:
                                  TextOverflow.ellipsis,
                              style: TextStyle(
                                color: value.isEmpty
                                    ? sub
                                    : txt,
                                fontSize: 13.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                      ),
                    ],
                  ),
                ),
              );
  void createMatch() {
            if (team1Controller.text.trim().isEmpty ||
                team2Controller.text.trim().isEmpty ||
                dateController.text.trim().isEmpty ||
                timeController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Team 1, Team 2, Match Date aur Match Time fill karein.',
                  ),
                ),
              );
              return;
            }

            final durationMinutes =
                int.tryParse(
                  durationController.text.trim(),
                ) ??
                180;

            adminMatches.value = [
              ...adminMatches.value,
              {
                'team1':
                    team1Controller.text.trim(),
                'team2':
                    team2Controller.text.trim(),
                'team1Logo': team1LogoController.text.trim(),
'team2Logo': team2LogoController.text.trim(),
                'team1Players':
                    team1PlayersController.text.trim(),
                'team2Players':
                    team2PlayersController.text.trim(),
                'date':
                    dateController.text.trim(),
                'time':
                    timeController.text.trim(),
                'matchFormat':
                    matchFormatController.text.trim(),
                'status': 'UPCOMING',
                'durationMinutes':
                    '$durationMinutes',
              },
            ];

            Navigator.pop(dialogContext);
          }
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 18,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 900,
                maxHeight:
                    MediaQuery.of(dialogStateContext)
                            .size
                            .height *
                        0.94,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    24,
                    22,
                    24,
                    22,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 58,
                            height: 58,
                            decoration:
                                const BoxDecoration(
                              color: soft,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons
                                  .sports_cricket_rounded,
                              color: pd,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Text(
                              'Create Match',
                              style: TextStyle(
                                color: txt,
                                fontSize: 28,
                                fontWeight:
                                    FontWeight.w800,
                              ),
                            ),
                          ),
                          InkWell(
                            borderRadius:
                                BorderRadius.circular(30),
                            onTap: () =>
                                Navigator.pop(
                              dialogContext,
                            ),
                            child: Container(
                              width: 52,
                              height: 52,
                              decoration:
                                  const BoxDecoration(
                                color: soft,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                color: pd,
                                size: 30,
                              ),
                            ),
                          ),
                        ],
                      ),
  const SizedBox(height: 22),

                      section(
                        Icons.groups_rounded,
                        'TEAM DETAILS',
                      ),

                      pair(
                        teamField(
                          team1Controller,
                          'Team 1',
                          'Enter Team 1 Name',
                        ),
                        teamField(
                          team2Controller,
                          'Team 2',
                          'Enter Team 2 Name',
                        ),
                      ),

                      const SizedBox(height: 12),

                      pair(
                        logoCard(
                          team1LogoController,
                          'Team 1',
                        ),
                        logoCard(
                          team2LogoController,
                          'Team 2',
                        ),
                      ),

                      const SizedBox(height: 22),

                      section(
                        Icons.groups_rounded,
                        'PLAYERS',
                      ),

                      playersCard(
                        team1PlayersController,
                        'Team 1',
                      ),

                      const SizedBox(height: 12),

                      playersCard(
                        team2PlayersController,
                        'Team 2',
                      ),

                      const SizedBox(height: 22),

                      section(
                        Icons.sports_cricket_rounded,
                        'MATCH DETAILS',
                      ),

                      textDetailCard(
                        Icons.sports_cricket_rounded,
                        'Match Format',
                        matchFormatController,
                        upperCase: true,
                        arrow: true,
                      ),

                      const SizedBox(height: 12),

                      pair(
                        pickerCard(
                          'Match Date',
                          'Select Date',
                          dateController.text,
                          Icons.calendar_month_rounded,
                          pickDate,
                        ),
                        pickerCard(
                          'Match Time',
                          'Select Time',
                          timeController.text,
                          Icons.access_time_rounded,
                          pickTime,
                        ),
                      ),

                      const SizedBox(height: 12),
  textDetailCard(
                        Icons.timer_outlined,
                        'Match Duration (Minutes)',
                        durationController,
                        keyboardType:
                            TextInputType.number,
                      ),

                      const SizedBox(height: 22),

                      const Divider(
                        color: Color(0xFFE4D4D9),
                      ),

                      const SizedBox(height: 14),

                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 54,
                              child: OutlinedButton(
                                style: OutlinedButton
                                    .styleFrom(
                                  foregroundColor: pd,
                                  side: const BorderSide(
                                    color: p,
                                    width: 1.5,
                                  ),
                                  shape:
                                      RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(
                                      28,
                                    ),
                                  ),
                                ),
  
                                onPressed: () =>
                                    Navigator.pop(
                                  dialogContext,
                                ),
                                child: const Text(
                                  'CANCEL',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight:
                                        FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 14),

                          Expanded(
                            child: SizedBox(
                              height: 54,
                              child: ElevatedButton(
                                style: ElevatedButton
                                    .styleFrom(
                                  backgroundColor: p,
                                  foregroundColor:
                                      Colors.white,
                                  elevation: 0,
                                  shape:
                                      RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(
                                      28,
                                    ),
                                  ),
                                ),
                                onPressed: createMatch,
                                child: const Text(
                                  'CREATE MATCH',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight:
                                        FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
  
  
                  
  static void _updatePlayerStats(
  BuildContext context,
  Map<String, dynamic> match,
) {
  final allPlayers = <String>[
  ...((match['team1Players'] ?? '').toString())
      .split(',')
      .map<String>((e) => e.trim())
      .where((String e) => e.isNotEmpty),
  ...((match['team2Players'] ?? '').toString())
      .split(',')
      .map<String>((e) => e.trim())
      .where((String e) => e.isNotEmpty),
];

  final statsControllers =
      <String, Map<String, TextEditingController>>{};

  final matchKey =
      '${match['team1']}_${match['team2']}_${match['date']}_${match['time']}';

  final matchStats = savedPlayerStats[matchKey] ?? {};

  for (final player in allPlayers) {
    final old = matchStats[player] ?? {};

    statsControllers[player] = {
      'runs': TextEditingController(text: '${old['runs'] ?? 0}'),
      'balls': TextEditingController(text: '${old['balls'] ?? 0}'),
      'fours': TextEditingController(text: '${old['fours'] ?? 0}'),
      'sixes': TextEditingController(text: '${old['sixes'] ?? 0}'),
      'wickets': TextEditingController(text: '${old['wickets'] ?? 0}'),
      'catches': TextEditingController(text: '${old['catches'] ?? 0}'),
    };
  }
bool completeMatchNow = false;
  showDialog(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
                    int getPoints(String player) {
            final c = statsControllers[player]!;

            final runs = int.tryParse(c['runs']!.text) ?? 0;
            final fours = int.tryParse(c['fours']!.text) ?? 0;
            final sixes = int.tryParse(c['sixes']!.text) ?? 0;
            final wickets = int.tryParse(c['wickets']!.text) ?? 0;
            final catches = int.tryParse(c['catches']!.text) ?? 0;

            return runs +
    (fours * 2) +
    (sixes * 4) +
    (wickets * 30) +
    (catches * 10);
          }

          Widget numberBox(
            TextEditingController controller,
          ) {
            return SizedBox(
              width: 48,
              child: TextField(
  controller: controller,
  keyboardType: TextInputType.number,
  textAlign: TextAlign.center,
scrollPhysics: const NeverScrollableScrollPhysics(),
enableInteractiveSelection: false,
  onTap: () {
    if (controller.text == '0') {
      controller.clear();
    }
  },

  
                decoration: const InputDecoration(
                  isDense: true,
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 4,
                  ),
                ),
              ),
            );
          }
final team1Name = (match['team1'] ?? '').toString();
final team2Name = (match['team2'] ?? '').toString();

String makeShortName(String name) {
  final words = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((e) => e.isNotEmpty)
      .toList();

  if (words.isEmpty) return '';

  if (words.length == 1) {
    final word = words.first.toUpperCase();
    return word.length <= 3
        ? word
        : word.substring(0, 3);
  }

  return words
      .take(3)
      .map((e) => e[0].toUpperCase())
      .join();
}

final team1Short = makeShortName(team1Name);
final team2Short = makeShortName(team2Name);

final flag1 = (match['team1Logo'] ?? '').toString();
final flag2 = (match['team2Logo'] ?? '').toString();
     final team1PlayerNames = (match['team1Players'] ?? '')
    .toString()
    .split(',')
    .map((e) => e.split('|').first.trim())
    .where((e) => e.isNotEmpty)
    .toSet();

const Color team1Color = Color(0xFF174EA6);
const Color team2Color = Color(0xFF146C43);

const Color runsDark = Color(0xFFB3261E);
const Color runsLight = Color(0xFFFFE7E5);

const Color ballsDark = Color(0xFF1565C0);
const Color ballsLight = Color(0xFFE3F2FD);

const Color foursDark = Color(0xFF7B3FB2);
const Color foursLight = Color(0xFFF1E6FA);

const Color sixesDark = Color(0xFFB57900);
const Color sixesLight = Color(0xFFFFF3D6);

const Color wicketsDark = Color(0xFF168447);
const Color wicketsLight = Color(0xFFE4F5EA);

const Color catchesDark = Color(0xFF087F8C);
const Color catchesLight = Color(0xFFE1F5F7);



Widget headerCell(
  String text,
  Color color, {
  int flex = 1,
}) {
  return Expanded(
    flex: flex,
    child: Container(
      height: 42,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    ),
  );
}
   Widget statCell(
  TextEditingController controller,
  Color darkColor,
  Color lightColor,
) {
  return Expanded(
    child: Container(
      height: 46,
      margin: const EdgeInsets.symmetric(
        horizontal: 1,
        vertical: 3,
      ),
      child: TextField(
  controller: controller,
  keyboardType: TextInputType.number,
  textAlign: TextAlign.center,
selectAllOnFocus: false,
  onTap: () {
  if (controller.text.trim() == '0') {
    controller.value = const TextEditingValue(
      text: '',
      selection: TextSelection.collapsed(offset: 0),
    );
  }
},
        style: TextStyle(
          color: darkColor,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: lightColor,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 13),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: darkColor,
              width: 1.2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: darkColor,
              width: 2,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    ),
  );
}       
    return AlertDialog(
  backgroundColor: const Color(0xFFFFF2EF),
  insetPadding: const EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 18,
  ),
  titlePadding: const EdgeInsets.fromLTRB(
    14,
    16,
    14,
    8,
  ),
  contentPadding: const EdgeInsets.fromLTRB(
    10,
    4,
    10,
    6,
  ),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(24),
  ),

  title: Text(
    '$flag1 $team1Short vs $team2Short $flag2',
    style: const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),

  content: SizedBox(
    width: double.maxFinite,
    height: 500,
    child: Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                height: 42,
                margin: const EdgeInsets.symmetric(
                  horizontal: 1,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 7),
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  color: const Color(0xFFD81B60),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Player',
                  style: const TextStyle(
  color: Colors.white,
  fontWeight: FontWeight.bold,
  fontSize: 12,
),
                ),
              ),
            ),      
          headerCell('Runs', runsDark),
            headerCell('Balls', ballsDark),
            headerCell('4s', foursDark),
            headerCell('6s', sixesDark),
            headerCell('Wkts', wicketsDark),
            headerCell('Catch', catchesDark),
            
          ],
        ),

        const SizedBox(height: 5),

        Expanded(
          child: ListView.builder(
            itemCount: allPlayers.length,
            itemBuilder: (context, index) {
              final player = allPlayers[index];
              final c = statsControllers[player]!;

              final cleanName =
                  player.split('|').first.trim();

              final isTeam1 =
                  team1PlayerNames.contains(cleanName);

              final playerColor =
                  isTeam1 ? team1Color : team2Color;

              return Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      height: 46,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 1,
                        vertical: 3,
                      ),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 7),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        color: playerColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        cleanName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
          statCell(
                    c['runs']!,
                    runsDark,
                    runsLight,
                  ),

                  statCell(
                    c['balls']!,
                    ballsDark,
                    ballsLight,
                  ),

                  statCell(
                    c['fours']!,
                    foursDark,
                    foursLight,
                  ),

                  statCell(
                    c['sixes']!,
                    sixesDark,
                    sixesLight,
                  ),

                  statCell(
                    c['wickets']!,
                    wicketsDark,
                    wicketsLight,
                  ),

                  statCell(
                    c['catches']!,
                    catchesDark,
                    catchesLight,
                  ),

                  
                ],
              );
            },
          ),
        ),
      ],
    ),
  ),

               
            
                        actionsPadding: const EdgeInsets.fromLTRB(8, 8, 8, 14),
actions: [
  Row(
    children: [
      Expanded(
        flex: 2,
        child: OutlinedButton(
          onPressed: () {
            Navigator.pop(dialogContext);
          },
          style: OutlinedButton.styleFrom(
            backgroundColor: const Color(0xFFFFE4E4),
            foregroundColor: const Color(0xFFC62828),
            side: const BorderSide(
              color: Color(0xFFE53935),
              width: 1.4,
            ),
            minimumSize: const Size(0, 44),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'CANCEL',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),

      const SizedBox(width: 6),

      Expanded(
        flex: 3,
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFEF9A3D),
              width: 1.3,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Checkbox(
                value: completeMatchNow,
                visualDensity: VisualDensity.compact,
                materialTapTargetSize:
                    MaterialTapTargetSize.shrinkWrap,
                onChanged: (value) {
                  setDialogState(() {
                    completeMatchNow = value ?? false;
                  });
                },
              ),
              const Flexible(
                child: Text(
                  'Complete Now',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      const SizedBox(width: 6),

      Expanded(
        flex: 2,
        child: ElevatedButton(
                onPressed: () {
                  for (final player in allPlayers) {
                    final c = statsControllers[player]!;

                    final runs =
                        int.tryParse(c['runs']!.text) ?? 0;
                    final balls =
    int.tryParse(c['balls']!.text) ?? 0;

final fours =
    int.tryParse(c['fours']!.text) ?? 0;
                    final sixes =
                        int.tryParse(c['sixes']!.text) ?? 0;
                    final wickets =
                        int.tryParse(c['wickets']!.text) ?? 0;
                    final catches =
                        int.tryParse(c['catches']!.text) ?? 0;

                    savedPlayerStats.putIfAbsent(
                      matchKey,
                      () => {},
                    );

                    savedPlayerStats[matchKey]![player] = {
                      'runs': runs,
                      'balls': balls,
                      'fours': fours,
                      'sixes': sixes,
                      'wickets': wickets,
                      'catches': catches,
                    };
}
                   

                 
        final updatedContests =
    List<Map<String, dynamic>>.from(joinedContests.value);

for (final contest in updatedContests) {
  if (contest['matchKey'] == matchKey ||
    (contest['team1'] == match['team1'] &&
     contest['team2'] == match['team2'])) {

    final rawPlayers = contest['selectedPlayers'];

List<Player> selectedPlayers =
    rawPlayers is List
        ? rawPlayers.whereType<Player>().toList()
        : <Player>[];

// Contest में players न हों तो इसी match की saved team लो
if (selectedPlayers.isEmpty) {
  int teamIndex = -1;

  for (int i = 0; i < savedTeamMatchKeys.length; i++) {
    final key = savedTeamMatchKeys[i];

    if (key.contains('${match['team1']}') &&
        key.contains('${match['team2']}')) {
      teamIndex = i;
      break;
    }
  }

  if (teamIndex >= 0 &&
      teamIndex < savedTeams.value.length) {
    selectedPlayers =
        List<Player>.from(savedTeams.value[teamIndex]);
  }
}

    final captainName = contest['captainName'] ?? '';
    final viceCaptainName = contest['viceCaptainName'] ?? '';

    double total = 0;

    for (final p in selectedPlayers) {
      Map<String, int>? playerStats;

      for (final entry in (savedPlayerStats[matchKey] ?? {}).entries) {
        if (entry.key.split('|').first.trim() ==
            p.name.trim()) {
          playerStats = entry.value;
          break;
        }
      }

      if (playerStats == null) continue;

      final basePoints =
          (playerStats['runs'] ?? 0) +
          ((playerStats['fours'] ?? 0) * 2) +
          ((playerStats['sixes'] ?? 0) * 4) +
          ((playerStats['wickets'] ?? 0) * 30) +
          ((playerStats['catches'] ?? 0) * 10);

      double multiplier = 1;

      if (p.name == captainName) {
        multiplier = 2;
      } else if (p.name == viceCaptainName) {
        multiplier = 1.5;
         }

      total += basePoints * multiplier;
    }

    contest['userPoints'] = total;
  
  }
}

joinedContests.value = updatedContests;
        final team1PlayerNames =
    (match['team1Players'] ?? '')
        .toString()
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

final team2PlayerNames =
    (match['team2Players'] ?? '')
        .toString()
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

int team1Runs = 0;
int team2Runs = 0;
int team1Wickets = 0;
int team2Wickets = 0;
                  
for (final player in team1PlayerNames) {
  team1Runs += savedPlayerStats[matchKey]?[player]?['runs'] ?? 0;
  team1Wickets += savedPlayerStats[matchKey]?
      [player]?['wickets'] ?? 0;
}


for (final player in team2PlayerNames) {
  team2Runs += savedPlayerStats[matchKey]?[player]?['runs'] ?? 0;
  team2Wickets += savedPlayerStats[matchKey]?
    [player]?['wickets'] ?? 0;
}
     for (final m in joinedMatches.value) {
  if (m.team1 == match['team1'] &&
      m.team2 == match['team2']) {

    m.team1Score = team1Runs;
    m.team2Score = team2Runs;
    m.team1Wickets = team1Wickets;
    m.team2Wickets = team2Wickets;
    
if (completeMatchNow) {
  m.status = 'COMPLETED';
}
    
    
    final matchingContests =
    updatedContests.where((contest) =>
        contest['matchKey'] == matchKey ||
        (contest['team1'] == m.team1 &&
         contest['team2'] == m.team2)
    ).toList();

if (matchingContests.isNotEmpty) {
  m.userPoints =
      ((matchingContests.first['userPoints'] ?? 0) as num).round();
}
  }
}
             
// My Matches refresh
joinedMatches.value =
    List<MatchModel>.from(joinedMatches.value);

// Home Page admin matches refresh
final updatedAdminMatches =
    List<Map<String, String>>.from(adminMatches.value);

for (final adminMatch in updatedAdminMatches) {
  if (adminMatch['team1'] == match['team1'] &&
      adminMatch['team2'] == match['team2']) {
    adminMatch['team1Score'] = team1Runs.toString();
    adminMatch['team2Score'] = team2Runs.toString();
    adminMatch['team1Wickets'] = team1Wickets.toString();
adminMatch['team2Wickets'] = team2Wickets.toString();
    if (completeMatchNow) {
  adminMatch['currentStatus'] = 'COMPLETED';
  adminMatch['status'] = 'COMPLETED';
}
    final currentStatus =
    adminMatch['currentStatus'] ??
    adminMatch['status'] ??
    '';

final bool joinedMatchCompleted =
    joinedMatches.value.any(
  (j) =>
      j.team1 == (adminMatch['team1'] ?? '') &&
      j.team2 == (adminMatch['team2'] ?? '') &&
      j.currentStatus == 'COMPLETED',
);
if (currentStatus == 'COMPLETED' ||
    joinedMatchCompleted) {
  adminMatch['finalScoreUpdated'] = 'true';

  final sameMatchContests = joinedContests.value.where(
    (c) =>
        c['team1'] == (adminMatch['team1'] ?? '') &&
        c['team2'] == (adminMatch['team2'] ?? ''),
  ).toList();

  for (final contest in sameMatchContests) {
    if (contest['selectedPlayers'] == null ||
        contest['matchKey'] == null) {
      continue;
    }

    final String contestName =
        (contest['contestName'] ?? 'Contest').toString();

    final int contestSpots =
        ((contest['spots'] ?? 0) as num).toInt();

   
    final players =
        List<Player>.from(contest['selectedPlayers'] as List);

    String contestMatchKey =
    contest['matchKey'].toString();

var matchStats =
    savedPlayerStats[contestMatchKey] ?? {};

// अगर पुराना/stale matchKey है तो current match के
// team names से सही saved stats ढूंढो
if (matchStats.isEmpty) {
  for (final entry in savedPlayerStats.entries) {
    final key = entry.key.toLowerCase();

    if (
  key.contains(
    (adminMatch['team1'] ?? '').toString().toLowerCase(),
  ) &&
  key.contains(
    (adminMatch['team2'] ?? '').toString().toLowerCase(),
  )
) {
      contestMatchKey = entry.key;
      matchStats = entry.value;
      break;
    }
  }
}

    final String captainName =
        contest['captainName']?.toString() ?? '';

    final String viceCaptainName =
        contest['viceCaptainName']?.toString() ?? '';

    double total = 0;

    for (final player in players) {
      Map<String, int>? stats;

      for (final entry in matchStats.entries) {
        if (entry.key.split('|').first.trim() ==
            player.name.trim()) {
          stats = entry.value;
          break;
        }
      }

      final runs = stats?['runs'] ?? 0;
      final fours = stats?['fours'] ?? 0;
      final sixes = stats?['sixes'] ?? 0;
      final wickets = stats?['wickets'] ?? 0;
      final catches = stats?['catches'] ?? 0;
          final basePoints =
          runs +
          (fours * 2) +
          (sixes * 4) +
          (wickets * 30) +
          (catches * 10);

      double points = basePoints.toDouble();

      if (player.name == captainName) {
        points *= 2;
      } else if (player.name == viceCaptainName) {
        points *= 1.5;
      }

      total += points;
    }

    final int userPoints = total.round();

    final leaderboard = <Map<String, dynamic>>[
      {
        'name': 'Cricket King',
        'points': 742.0,
      },
      if (contestSpots != 2)
        {
          'name': 'Super XI',
          'points': 711.0,
        },
      {
        'name': 'You',
        'points': userPoints.toDouble(),
      },
    ];
        leaderboard.sort(
      (a, b) => (b['points'] as double)
          .compareTo(a['points'] as double),
    );

    final int rank =
        leaderboard.indexWhere(
              (item) => item['name'] == 'You',
            ) +
            1;

    final String teamKey =
    (contest['teamName'] ??
            contest['selectedTeam'] ??
            contest['teamIndex'] ??
            contest['teamId'] ??
            '')
        .toString();

final String contestId =
    (contest['contestId'] ??
            contest['id'] ??
            '')
        .toString()
        .trim();

final String claimMatchKey =
    (contest['matchKey'] ?? contestMatchKey)
        .toString();

final String claimKey = contestId.isNotEmpty
    ? '$contestId-$teamKey'
    : '$contestName-$teamKey';

final String description =
    '${adminMatch['team1']} vs ${adminMatch['team2']}';

final bool alreadyPaid =
    transactionHistory.value.any((tx) {
  if (tx['title'] != 'Winning') return false;

  final savedContestId =
      (tx['contestId'] ?? '').toString().trim();

  final savedTeamKey =
      (tx['teamKey'] ?? '').toString().trim();

  if (contestId.isNotEmpty &&
      savedContestId.isNotEmpty) {
    return savedContestId == contestId &&
        savedTeamKey == teamKey;
  }

  final savedClaimKey =
      (tx['claimKey'] ?? '').toString().trim();

  if (savedClaimKey.isNotEmpty) {
    return savedClaimKey == claimKey;
  }

  return tx['subtitle'] == contestName &&
      tx['description'] == description &&
      savedTeamKey == teamKey;
});

if (alreadyPaid) {
  final updated =
      Set<String>.from(claimedWinnings.value);

  updated.add(claimKey);
  claimedWinnings.value = updated;
  continue;
}
        double winningAmount = 0.0;

final rawSlabs = contest['prizeSlabs'];

if (rawSlabs is List) {
  for (final rawSlab in rawSlabs) {
    if (rawSlab is! Map) continue;

    final from =
        int.tryParse('${rawSlab['from'] ?? ''}') ?? 0;
    final to =
        int.tryParse('${rawSlab['to'] ?? ''}') ?? from;
    final prize = double.tryParse(
      '${rawSlab['amount'] ?? rawSlab['prize'] ?? ''}',
    ) ??
    0.0;

    if (rank >= from && rank <= to) {
      winningAmount = prize;
      break;
    }
  }
}

    if (winningAmount > 0) {
      walletBalance.value += winningAmount;

      final now = DateTime.now();

      transactionHistory.value = [
        ...transactionHistory.value,
        {
          
  'title': 'Winning',
  'subtitle': contestName,
  'winningType':
    (contest['h2hWinningType'] ?? contest['winningType'] ?? '').toString(),
  'rank': rank,
  'claimKey': claimKey,
  'contestId': contestId,
  'matchKey': claimMatchKey,
  'teamKey': teamKey,
  'description': description,
  'dateTime':
      '${now.day.toString().padLeft(2, '0')}/'
      '${now.month.toString().padLeft(2, '0')}/'
      '${now.year} '
      '${now.hour.toString().padLeft(2, '0')}:'
      '${now.minute.toString().padLeft(2, '0')}',
  'amount': winningAmount,
},
      ];
    }

    final updated =
        Set<String>.from(claimedWinnings.value);

    updated.add(claimKey);
    claimedWinnings.value = updated;
  }
}
    
  }
}

adminMatches.value = updatedAdminMatches;
          
                  Navigator.pop(dialogContext);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Player stats saved'),
                    ),
                  );
                },
style: ElevatedButton.styleFrom(
  backgroundColor: const Color(0xFF0B6B45),
  foregroundColor: Colors.white,
  elevation: 0,
  minimumSize: const Size(0, 44),
  padding: const EdgeInsets.symmetric(horizontal: 4),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  ),
),
child: const FittedBox(
  fit: BoxFit.scaleDown,
  child: Text(
    'SAVE STATS',
    style: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 13,
    ),
  ),
),
),
),
],
),
],
);
        },
      );
    },
  );
}
void _editMatch(Map<String, String> match) {
 final oldTeam1 = match['team1'] ?? '';
final oldTeam2 = match['team2'] ?? '';
final oldDate = match['date'] ?? '';
final oldTime = match['time'] ?? '';

final oldSavedTeamKey =
    '${oldTeam1}_${oldTeam2}_${oldDate}_${oldTime}';
  final team1Controller =
      TextEditingController(text: match['team1'] ?? '');

  final team2Controller =
      TextEditingController(text: match['team2'] ?? '');

  final team1LogoController =
      TextEditingController(text: match['team1Logo'] ?? '');

  final team2LogoController =
      TextEditingController(text: match['team2Logo'] ?? '');

  final dateController =
      TextEditingController(text: match['date'] ?? '');

  final timeController =
      TextEditingController(text: match['time'] ?? '');
  final durationController = TextEditingController(
  text: match['durationMinutes'] ?? '180',
);
final team1PlayersController = TextEditingController(
  text: match['team1Players'] ?? '',
);

final team2PlayersController = TextEditingController(
  text: match['team2Players'] ?? '',
);
  showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Edit Match'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: team1Controller,
                decoration: const InputDecoration(
                  labelText: 'Team 1',
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: team1LogoController,
                decoration: const InputDecoration(
                  labelText: 'Team 1 Logo / Flag',
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: team2Controller,
                decoration: const InputDecoration(
                  labelText: 'Team 2',
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: team2LogoController,
                decoration: const InputDecoration(
                  labelText: 'Team 2 Logo / Flag',
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: dateController,
                decoration: const InputDecoration(
                  labelText: 'Match Date',
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: timeController,
                decoration: const InputDecoration(
                  labelText: 'Match Time',
                  
          ),
        ),
         const SizedBox(height: 12),

TextField(
  controller: durationController,
  keyboardType: TextInputType.number,
  decoration: const InputDecoration(
    labelText: 'Match Duration (Minutes)',
    hintText: '180',
  ),
),             
            const SizedBox(height: 12),

TextField(
  controller: team1PlayersController,
  maxLines: 4,
  decoration: const InputDecoration(
    labelText: 'Team 1 Players',
    hintText: 'Rohit|BAT, Pant|WK, Bumrah|BOWL',
  ),
),

const SizedBox(height: 12),

TextField(
  controller: team2PlayersController,
  maxLines: 4,
  decoration: const InputDecoration(
    labelText: 'Team 2 Players',
    hintText: 'Root|BAT, Buttler|WK, Archer|BOWL',
  ),
),
              ],
      ),
    ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              final updated =
                  List<Map<String, String>>.from(adminMatches.value);

              final index = updated.indexOf(match);

              if (index != -1) {
                updated[index] = {
                  ...match,
                  'team1': team1Controller.text.trim(),
                  'team2': team2Controller.text.trim(),
                  'team1Logo': team1LogoController.text.trim(),
                  'team2Logo': team2LogoController.text.trim(),
         'team1Players': team1PlayersController.text.trim(),
'team2Players': team2PlayersController.text.trim(),      
                  'date': dateController.text.trim(),
                  'time': timeController.text.trim(),
                  'durationMinutes': durationController.text.trim(),
                };
final newSavedTeamKey =
    '${team1Controller.text.trim()}_'
    '${team2Controller.text.trim()}_'
    '${dateController.text.trim()}_'
    '${timeController.text.trim()}';

for (int i = 0; i < savedTeamMatchKeys.length; i++) {
  if (savedTeamMatchKeys[i] == oldSavedTeamKey) {
    savedTeamMatchKeys[i] = newSavedTeamKey;
  }
}
               
                final editedStartTime = _parseMatchDateTime(
  dateController.text.trim(),
  timeController.text.trim(),
);

final editedMinutes =
    int.tryParse(durationController.text.trim()) ?? 0;
                final now = DateTime.now();

String newStatus = match['status'] ?? 'UPCOMING';

if (editedStartTime != null && editedMinutes > 0) {
  final editedEndTime =
      editedStartTime.add(Duration(minutes: editedMinutes));

  if (now.isBefore(editedStartTime)) {
    newStatus = 'UPCOMING';
  } else if (now.isBefore(editedEndTime)) {
    newStatus = 'LIVE';
  } else {
    newStatus = 'COMPLETED';
  }
}

if (index != -1) {
  updated[index]['status'] = newStatus;
  updated[index]['currentStatus'] = newStatus;

  if (newStatus == 'COMPLETED' &&
    (match['currentStatus'] ?? match['status']) != 'COMPLETED') {
  updated[index]['finalScoreUpdated'] = 'false';
  updated[index]['completedAt'] =
      DateTime.now().toIso8601String();
}
}

adminMatches.value = updated;

final syncedJoinedMatches = joinedMatches.value.map((j) {
  if (j.team1 == (match['team1'] ?? '') &&
      j.team2 == (match['team2'] ?? '')) {
    final synced = MatchModel(
      team1: team1Controller.text.trim(),
      team2: team2Controller.text.trim(),
      team1Flag: j.team1Flag,
      team2Flag: j.team2Flag,
      title:
          '${team1Controller.text.trim()} vs ${team2Controller.text.trim()}',
      time: timeController.text.trim(),
      status: newStatus,
      userPoints: j.userPoints,
      startTime: editedStartTime ?? j.startTime,
liveDuration: editedMinutes > 0
    ? Duration(minutes: editedMinutes)
    : j.liveDuration,
completedAt: newStatus == 'COMPLETED'
    ? (j.completedAt ?? DateTime.now())
    : j.completedAt,
winner: j.winner,
      team1Score: j.team1Score,
      team2Score: j.team2Score,
      userRank: j.userRank,
      entryFee: j.entryFee,
      prizePool: j.prizePool,
      contestName: j.contestName,
      contestSpots: j.contestSpots,
      team1Players: team1PlayersController.text.trim(),
      team2Players: team2PlayersController.text.trim(),
    );

    synced.team1Wickets =
    int.tryParse(updated[index]['team1Wickets'] ?? '') ??
        j.team1Wickets;

synced.team2Wickets =
    int.tryParse(updated[index]['team2Wickets'] ?? '') ??
        j.team2Wickets;

    return synced;
  }

  return j;
}).toList();

joinedMatches.value = syncedJoinedMatches;
                }
              Navigator.pop(dialogContext);
            },
            child: const Text('SAVE'),
          ),
        ],
      );
    },
  );
}
  @override
  Widget build(BuildContext context) {
    final sortedMatches =
    List<Map<String, String>>.from(adminMatches.value);

final today = DateTime.now();
final todayOnly =
    DateTime(today.year, today.month, today.day);

DateTime matchDate(Map<String, String> match) {
  return _parseMatchDateTime(
        match['date'] ?? '',
        match['time'] ?? '',
      ) ??
      DateTime(2000);
}

sortedMatches.sort((a, b) {
  final aDt = matchDate(a);
  final bDt = matchDate(b);

  final aDay = DateTime(aDt.year, aDt.month, aDt.day);
  final bDay = DateTime(bDt.year, bDt.month, bDt.day);

  int group(DateTime day) {
    if (day == todayOnly) return 0;       // TODAY
    if (day.isAfter(todayOnly)) return 1; // FUTURE
    return 2;                             // PAST
  }

  final aGroup = group(aDay);
  final bGroup = group(bDay);

  if (aGroup != bGroup) {
    return aGroup.compareTo(bGroup);
  }

  // Future dates: nearest first
  if (aGroup == 1 && aDay != bDay) {
    return aDay.compareTo(bDay);
  }

  // Past dates: latest first
  if (aGroup == 2 && aDay != bDay) {
    return bDay.compareTo(aDay);
  }

  // Same date: latest time first
  return bDt.compareTo(aDt);
});
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Matches'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
  margin: const EdgeInsets.fromLTRB(24, 18, 24, 20),
  decoration: BoxDecoration(
    color: const Color(0xFFE8F5E9),
    borderRadius: BorderRadius.circular(18),
    border: Border.all(
      color: const Color(0xFFA5D6A7),
      width: 1.2,
    ),
    boxShadow: const [
      BoxShadow(
        color: Color(0x18000000),
        blurRadius: 8,
        offset: Offset(0, 3),
      ),
    ],
  ),
  child: InkWell(
    borderRadius: BorderRadius.circular(18),
    onTap: _createMatch,
    child: const Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 16,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 23,
            backgroundColor: Color(0xFF43A047),
            child: Icon(
              Icons.add,
              size: 30,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create New Match',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Add teams, players and schedule',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF557A58),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            size: 28,
            color: Color(0xFF9A3C50),
          ),
        ],
      ),
    ),
  ),
),
          const SizedBox(height: 20),

          if (adminMatches.value.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(30),
                child: Text(
                  'No matches created yet',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),

          
          ...sortedMatches.asMap().entries.map((entry) {
  final index = entry.key;
  final match = entry.value;

  final currentDt = matchDate(match);
  final currentDay =
      DateTime(currentDt.year, currentDt.month, currentDt.day);

  DateTime? previousDay;

  if (index > 0) {
    final previousDt =
    matchDate(sortedMatches[index - 1]);
    previousDay = DateTime(
      previousDt.year,
      previousDt.month,
      previousDt.day,
    );
  }

  final showRibbon =
      index == 0 || currentDay != previousDay;

  String ribbonText;

  final tomorrow =
      todayOnly.add(const Duration(days: 1));
  final yesterday =
      todayOnly.subtract(const Duration(days: 1));

  if (currentDay == todayOnly) {
    ribbonText = 'TODAY';
  } else if (currentDay == tomorrow) {
    ribbonText = 'TOMORROW';
  } else if (currentDay == yesterday) {
    ribbonText = 'YESTERDAY';
  } else {
    ribbonText =
        '${currentDt.day.toString().padLeft(2, '0')}/'
        '${currentDt.month.toString().padLeft(2, '0')}/'
        '${currentDt.year}';
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      if (showRibbon)
        Container(
          margin: const EdgeInsets.only(
            top: 8,
            bottom: 10,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFC84F68),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            ribbonText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

      Card(
    margin: const EdgeInsets.only(bottom: 12),
    elevation: 2,
    color: const Color(0xFFFFD9DE),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
      side: const BorderSide(
        color: Color(0xFFE99AAA),
        width: 1.2,
      ),
    ),
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),

      leading: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: const Color(0xFFC84F68),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(
          Icons.sports_cricket,
          color: Colors.white,
          size: 26,
        ),
      ),

      title: Text(
  '${(match['team1Logo'] ?? match['team1Flag'] ?? '').toString().trim().isNotEmpty
      ? (match['team1Logo'] ?? match['team1Flag']).toString()
      : _flagForTeam(match['team1'] ?? '')} '
  '${_shortTeamName(match['team1'] ?? '')}'
  '  vs  '
  '${_shortTeamName(match['team2'] ?? '')} '
  '${(match['team2Logo'] ?? match['team2Flag'] ?? '').toString().trim().isNotEmpty
      ? (match['team2Logo'] ?? match['team2Flag']).toString()
      : _flagForTeam(match['team2'] ?? '')}'
  '  •  ${match['matchFormat'] ?? ''}',
  style: const TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.bold,
    color: Color(0xFF3F252B),
  ),
),

subtitle: Padding(
  padding: const EdgeInsets.only(top: 5),
  child: Text(
    '${match['date'] ?? ''} • ${match['time'] ?? ''}\n'
    '${match['status'] ?? ''}',
    style: const TextStyle(
      fontSize: 14,
      height: 1.35,
      fontWeight: FontWeight.w600,
      color: Color(0xFF70454F),
    ),
  ),
),

      isThreeLine: true,

      trailing: const Icon(
        Icons.chevron_right,
        size: 28,
        color: Color(0xFFA83F57),
      ),
      onTap: () {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('EDIT MATCH'),
              onTap: () {
  Navigator.pop(context);
  _editMatch(match);
},
            ),
         
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('DELETE MATCH'),
              onTap: () {
                Navigator.pop(context);

                final updated =
                    List<Map<String, String>>.from(adminMatches.value);

                updated.remove(match);
                adminMatches.value = updated;
final deletedTeam1 = match['team1'] ?? '';
final deletedTeam2 = match['team2'] ?? '';
createdContests.removeWhere((c) {
  return (c['team1'] ?? '') == deletedTeam1 &&
      (c['team2'] ?? '') == deletedTeam2;
});
final deletedMatchName =
    '$deletedTeam1 vs $deletedTeam2'
        .trim()
        .toLowerCase();

// My Matches से उसी match को हटाओ
joinedMatches.value =
    joinedMatches.value.where((m) {
  return !(m.team1 == deletedTeam1 &&
      m.team2 == deletedTeam2);
}).toList();

// My Contests से उसी match के contests हटाओ
joinedContests.value =
    joinedContests.value.where((c) {
  final contestMatch =
      (c['match'] ?? '').toString().trim().toLowerCase();

  return contestMatch != deletedMatchName;
}).toList();

// My Teams से उसी match की saved teams हटाओ
final keyPrefix =
    '${deletedTeam1}_${deletedTeam2}_'.toLowerCase();

for (int i = savedTeamMatchKeys.length - 1;
    i >= 0;
    i--) {
  if (savedTeamMatchKeys[i]
      .toLowerCase()
      .startsWith(keyPrefix)) {

    savedTeamMatchKeys.removeAt(i);

    if (i < savedTeams.value.length) {
      final updatedTeams =
          List<List<Player>>.from(savedTeams.value);

      updatedTeams.removeAt(i);
      savedTeams.value = updatedTeams;
    }
  }
}
              },
            ),
          ],
        ),
      );
    },
  );
},
              ),
            ),
      
              ],
  );
}),
        ],
      ),
    );
  }
}
