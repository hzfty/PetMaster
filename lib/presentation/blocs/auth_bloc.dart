import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:petmaster_app/presentation/blocs/auth_event.dart';
import 'package:petmaster_app/presentation/blocs/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late StreamSubscription<User?> _authStateSubscription;

  AuthBloc({required FirebaseAuth firebaseAuth})
      : _firebaseAuth = firebaseAuth,
        super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<AuthStateChanged>(_onAuthStateChanged);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<Guest>(_onGuest);

    _authStateSubscription = _firebaseAuth.authStateChanges().listen((user) {
      add(AuthStateChanged(user: user));
    });
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final isGuest = prefs.getBool('isGuest') ?? false;

    final user = await _firebaseAuth.authStateChanges().first;

    if (user != null) {
      emit(Authenticated());
    } else if (isGuest) {
      emit(GuestState());
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onAuthStateChanged(
      AuthStateChanged event, Emitter<AuthState> emit) async {
    final user = event.user;
    final prefs = await SharedPreferences.getInstance();
    final isGuest = prefs.getBool('isGuest') ?? false;

    if (user != null) {
      emit(Authenticated());
    } else if (isGuest) {
      emit(GuestState());
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onLoginRequested(
      LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
    } on FirebaseAuthException catch (e) {
      emit(AuthError(error: e.message ?? 'Неизвестная ошибка'));
    }
  }

  Future<void> _onRegisterRequested(
      RegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'username': event.username,
        'email': event.email,
      });
    } on FirebaseAuthException catch (e) {
      emit(AuthError(error: e.message ?? 'Неизвестная ошибка'));
    }
  }

  Future<void> _onLogoutRequested(
      LogoutRequested event, Emitter<AuthState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isGuest');

    await _firebaseAuth.signOut();
  }

  Future<void> _onGuest(Guest event, Emitter<AuthState> emit) async {
    emit(GuestState());
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isGuest', true);
  }

  @override
  Future<void> close() {
    _authStateSubscription.cancel();
    return super.close();
  }
}

class AuthStateChanged extends AuthEvent {
  final User? user;
  AuthStateChanged({required this.user});
}
