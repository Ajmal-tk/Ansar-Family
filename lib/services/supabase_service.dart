import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../config/supabase_config.dart';
import '../models/profile_model.dart';
import '../models/post_model.dart';
import '../models/fee_model.dart';
import '../models/family_member_model.dart';

class SupabaseService {
  static final SupabaseService instance = SupabaseService._internal();
  SupabaseService._internal();

  SupabaseClient? get client {
    if (SupabaseConfig.isConfigured) {
      try {
        return Supabase.instance.client;
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  // --- MOCK IN-MEMORY DATA STORE FOR ZERO-COST DEMO MODE WHEN NOT CONFIGURED ---
  final Map<String, ProfileModel> _mockProfiles = {
    'demo-admin': ProfileModel(
      id: 'demo-admin',
      username: 'admin',
      fullName: 'Mahallu President',
      role: 'admin',
      status: 'approved',
      phone: '+91 94470 12345',
      address: 'Juma Masjid Road, Malappuram, Kerala 676505',
    ),
    'demo-management': ProfileModel(
      id: 'demo-management',
      username: 'manager',
      fullName: 'Mahallu Secretary',
      role: 'management',
      status: 'approved',
      phone: '+91 98471 23456',
      address: 'Town Hall Rd, Calicut, Kerala 673001',
    ),
    'demo-member': ProfileModel(
      id: 'demo-member',
      username: 'ansar_member',
      fullName: 'Tariq Al-Mansoor',
      role: 'member',
      status: 'approved',
      phone: '+91 97452 34567',
      address: 'Near Juma Masjid, Ponnani, Kerala 679577',
    ),
    'demo-pending': ProfileModel(
      id: 'demo-pending',
      username: 'applicant_user',
      fullName: 'Fatima Zohra',
      role: 'member',
      status: 'pending',
      phone: '+91 94953 45678',
      address: 'Green Valley, Ernakulam, Kerala 682011',
    ),
  };

  final List<FamilyMemberModel> _mockFamilyMembers = [
    FamilyMemberModel(
      id: 'fam-1',
      userId: 'demo-member',
      name: 'Aisha Al-Mansoor',
      relation: 'Spouse',
      age: 32,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    FamilyMemberModel(
      id: 'fam-2',
      userId: 'demo-member',
      name: 'Zayd Al-Mansoor',
      relation: 'Child',
      age: 6,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    FamilyMemberModel(
      id: 'fam-3',
      userId: 'demo-pending',
      name: 'Youssef Zohra',
      relation: 'Child',
      age: 4,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  final List<PostModel> _mockPosts = [
    PostModel(
      id: 'post-1',
      userId: 'demo-management',
      content: 'Assalamu Alaikum family! Monthly Mahallu Halaqah & food drive this Saturday at 10 AM.',
      createdAt: DateTime.now().subtract(const Duration(hours: 14)),
      authorName: 'Mahallu Secretary',
      authorRole: 'management',
    ),
    PostModel(
      id: 'post-2',
      userId: 'demo-member',
      content: 'Assistance request: Looking for volunteer tutors for high school mathematics.',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      authorName: 'Tariq Al-Mansoor',
      authorRole: 'member',
    ),
  ];

  final List<FeeModel> _mockFees = [
    FeeModel(
      id: 'fee-1',
      userId: 'demo-member',
      amount: 500.0,
      currency: 'INR',
      period: '2026-Q1',
      status: 'paid',
      paymentDate: DateTime.now().subtract(const Duration(days: 10)),
      createdBy: 'demo-management',
      userName: 'Tariq Al-Mansoor',
    ),
  ];

  String? _mockCurrentUserId = 'demo-admin';

  // --- AUTHENTICATION ---
  User? get currentUser => client?.auth.currentUser;

  String get currentUserId {
    if (client != null && currentUser != null) {
      return currentUser!.id;
    }
    return _mockCurrentUserId ?? 'demo-member';
  }

  Future<AuthResponse?> signUp({
    required String username,
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String address,
  }) async {
    if (client != null) {
      final res = await client!.auth.signUp(
        email: email,
        password: password,
        data: {
          'username': username,
          'full_name': fullName,
          'phone': phone,
          'address': address,
          'role': 'member',
          'status': 'pending',
        },
      );
      return res;
    } else {
      // Mock signup logic
      final newId = const Uuid().v4();
      _mockProfiles[newId] = ProfileModel(
        id: newId,
        username: username.isNotEmpty ? username : email.split('@').first,
        fullName: fullName,
        phone: phone,
        address: address,
        role: 'member',
        status: 'pending',
        updatedAt: DateTime.now(),
      );
      _mockCurrentUserId = newId;
      return null;
    }
  }

  Future<AuthResponse?> signIn({
    required String emailOrUsername,
    required String password,
  }) async {
    if (client != null) {
      String targetEmail = emailOrUsername.trim();

      // If user provided a username instead of email, resolve email from public.profiles
      if (!targetEmail.contains('@')) {
        try {
          final res = await client!
              .from('profiles')
              .select('id, username')
              .eq('username', targetEmail)
              .maybeSingle();

          if (res != null) {
            // Find corresponding email or query auth profile
            final String uId = res['id'];
            final profile = await fetchProfile(uId);
            if (profile != null && profile.username != null) {
              // Standard sign in fallback
              targetEmail = '${profile.username}@ansarfamily.org';
            }
          }
        } catch (e) {
          debugPrint("Username lookup note: $e");
        }
      }

      return await client!.auth.signInWithPassword(
        email: targetEmail,
        password: password,
      );
    } else {
      // Mock sign in lookup by email or username
      final term = emailOrUsername.toLowerCase().trim();
      if (term.contains('admin')) {
        _mockCurrentUserId = 'demo-admin';
      } else if (term.contains('manager') || term.contains('management')) {
        _mockCurrentUserId = 'demo-management';
      } else if (term.contains('pending') || term.contains('applicant')) {
        _mockCurrentUserId = 'demo-pending';
      } else {
        _mockCurrentUserId = 'demo-member';
      }
      return null;
    }
  }

  Future<void> signOut() async {
    if (client != null) {
      await client!.auth.signOut();
    } else {
      _mockCurrentUserId = null;
    }
  }

  void switchMockRole(String role) {
    if (role == 'admin') _mockCurrentUserId = 'demo-admin';
    if (role == 'management') _mockCurrentUserId = 'demo-management';
    if (role == 'member') _mockCurrentUserId = 'demo-member';
    if (role == 'pending') _mockCurrentUserId = 'demo-pending';
  }

  // --- PROFILES ---
  Future<ProfileModel?> fetchProfile(String userId) async {
    if (client != null) {
      try {
        final res = await client!
            .from('profiles')
            .select()
            .eq('id', userId)
            .maybeSingle();
        if (res != null) {
          return ProfileModel.fromJson(res);
        }
      } catch (e) {
        debugPrint("Error fetching profile: $e");
      }
    }
    return _mockProfiles[userId] ?? _mockProfiles['demo-member'];
  }

  Future<List<ProfileModel>> fetchPendingProfiles() async {
    if (client != null) {
      try {
        final res = await client!
            .from('profiles')
            .select()
            .eq('status', 'pending');
        return (res as List).map((e) => ProfileModel.fromJson(e)).toList();
      } catch (e) {
        debugPrint("Error fetching pending profiles: $e");
      }
    }
    return _mockProfiles.values.where((p) => p.status == 'pending').toList();
  }

  Future<List<ProfileModel>> fetchAllProfiles() async {
    if (client != null) {
      try {
        final res = await client!.from('profiles').select();
        return (res as List).map((e) => ProfileModel.fromJson(e)).toList();
      } catch (e) {
        debugPrint("Error fetching all profiles: $e");
      }
    }
    return _mockProfiles.values.toList();
  }

  Future<bool> updateProfileStatus(String userId, String status) async {
    if (client != null) {
      try {
        await client!.from('profiles').update({
          'status': status,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', userId);
        return true;
      } catch (e) {
        debugPrint("Error updating status: $e");
        return false;
      }
    } else {
      if (_mockProfiles.containsKey(userId)) {
        _mockProfiles[userId] = _mockProfiles[userId]!.copyWith(status: status);
      }
      return true;
    }
  }

  Future<bool> updateProfileRole(String userId, String role) async {
    if (client != null) {
      try {
        await client!.from('profiles').update({
          'role': role,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', userId);
        return true;
      } catch (e) {
        debugPrint("Error updating role: $e");
        return false;
      }
    } else {
      if (_mockProfiles.containsKey(userId)) {
        _mockProfiles[userId] = _mockProfiles[userId]!.copyWith(role: role);
      }
      return true;
    }
  }

  // --- FAMILY MEMBERS ---
  Future<List<FamilyMemberModel>> fetchFamilyMembers(String userId) async {
    if (client != null) {
      try {
        final res = await client!
            .from('family_members')
            .select()
            .eq('user_id', userId);
        return (res as List).map((e) => FamilyMemberModel.fromJson(e)).toList();
      } catch (e) {
        debugPrint("Error fetching family members: $e");
      }
    }
    return _mockFamilyMembers.where((m) => m.userId == userId).toList();
  }

  Future<bool> addFamilyMember({
    required String name,
    required String relation,
    required int age,
  }) async {
    final uId = currentUserId;
    if (client != null) {
      try {
        await client!.from('family_members').insert({
          'user_id': uId,
          'name': name,
          'relation': relation,
          'age': age,
        });
        return true;
      } catch (e) {
        debugPrint("Error adding family member: $e");
        return false;
      }
    } else {
      _mockFamilyMembers.add(FamilyMemberModel(
        id: const Uuid().v4(),
        userId: uId,
        name: name,
        relation: relation,
        age: age,
        createdAt: DateTime.now(),
      ));
      return true;
    }
  }

  Future<bool> deleteFamilyMember(String id) async {
    if (client != null) {
      try {
        await client!.from('family_members').delete().eq('id', id);
        return true;
      } catch (e) {
        return false;
      }
    } else {
      _mockFamilyMembers.removeWhere((m) => m.id == id);
      return true;
    }
  }

  // --- POSTS / COMMUNITY ASSISTANCE ---
  Future<List<PostModel>> fetchPosts() async {
    if (client != null) {
      try {
        final res = await client!
            .from('posts')
            .select('*, profiles(full_name, role)')
            .order('created_at', ascending: false);
        return (res as List).map((e) => PostModel.fromJson(e)).toList();
      } catch (e) {
        debugPrint("Error fetching posts: $e");
      }
    }
    return List.from(_mockPosts);
  }

  Future<bool> createPost(String content) async {
    final uId = currentUserId;
    if (client != null) {
      try {
        await client!.from('posts').insert({
          'user_id': uId,
          'content': content,
        });
        return true;
      } catch (e) {
        debugPrint("Error creating post: $e");
        return false;
      }
    } else {
      final currentProf = _mockProfiles[uId];
      _mockPosts.insert(
        0,
        PostModel(
          id: const Uuid().v4(),
          userId: uId,
          content: content,
          createdAt: DateTime.now(),
          authorName: currentProf?.fullName ?? 'Community Member',
          authorRole: currentProf?.role ?? 'member',
        ),
      );
      return true;
    }
  }

  Future<bool> deletePost(String id) async {
    if (client != null) {
      try {
        await client!.from('posts').delete().eq('id', id);
        return true;
      } catch (e) {
        return false;
      }
    } else {
      _mockPosts.removeWhere((p) => p.id == id);
      return true;
    }
  }

  // --- MEMBERSHIP FEES & FINANCIALS ---
  Future<List<FeeModel>> fetchUserFees(String userId) async {
    if (client != null) {
      try {
        final res = await client!
            .from('membership_fees')
            .select('*, profiles(full_name)')
            .eq('user_id', userId)
            .order('payment_date', ascending: false);
        return (res as List).map((e) => FeeModel.fromJson(e)).toList();
      } catch (e) {
        debugPrint("Error fetching fees: $e");
      }
    }
    return _mockFees.where((f) => f.userId == userId).toList();
  }

  Future<List<FeeModel>> fetchAllFees() async {
    if (client != null) {
      try {
        final res = await client!
            .from('membership_fees')
            .select('*, profiles(full_name)')
            .order('payment_date', ascending: false);
        return (res as List).map((e) => FeeModel.fromJson(e)).toList();
      } catch (e) {
        debugPrint("Error fetching all fees: $e");
      }
    }
    return List.from(_mockFees);
  }

  Future<bool> recordFee(FeeModel fee) async {
    if (client != null) {
      try {
        await client!.from('membership_fees').insert(fee.toJson());
        return true;
      } catch (e) {
        debugPrint("Error recording fee: $e");
        return false;
      }
    } else {
      _mockFees.insert(0, fee);
      return true;
    }
  }
}
