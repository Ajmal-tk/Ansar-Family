import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  // --- AUTHENTICATION ---
  User? get currentUser => client?.auth.currentUser;

  String get currentUserId => currentUser?.id ?? '';

  Future<AuthResponse?> signUp({
    required String username,
    String? email,
    required String password,
    required String fullName,
    required String phone,
    required String address,
  }) async {
    if (client == null) {
      throw const AuthException('Database client is not configured.');
    }
    if (email == null || email.isEmpty) {
      throw const AuthException(
        'Supabase password auth requires an email address.',
      );
    }
    return await client!.auth.signUp(
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
  }

  Future<AuthResponse?> signIn({
    required String emailOrUsername,
    required String password,
  }) async {
    if (client == null) {
      throw const AuthException('Database client is not configured.');
    }

    String targetEmail = emailOrUsername.trim();

    // If user provided a username instead of email, resolve actual registered email
    if (!targetEmail.contains('@')) {
      final cleanUsername = targetEmail.toLowerCase().trim();
      try {
        // 1. Try secure RPC function (resolves authentic email securely)
        final rpcEmail = await client!.rpc(
          'get_email_for_username',
          params: {'p_username': cleanUsername},
        );

        if (rpcEmail != null && rpcEmail.toString().trim().isNotEmpty) {
          targetEmail = rpcEmail.toString().trim();
        } else {
          // 2. Fallback: check public.profiles safely without failing on missing email column
          final res = await client!
              .from('profiles')
              .select('id, username')
              .ilike('username', cleanUsername)
              .maybeSingle();

          if (res != null) {
            try {
              final withEmail = await client!
                  .from('profiles')
                  .select('email')
                  .eq('id', res['id'])
                  .maybeSingle();
              if (withEmail != null &&
                  withEmail['email'] != null &&
                  withEmail['email'].toString().trim().isNotEmpty) {
                targetEmail = withEmail['email'].toString().trim();
              } else {
                targetEmail = '$cleanUsername@ansarfamily.org';
              }
            } catch (_) {
              targetEmail = '$cleanUsername@ansarfamily.org';
            }
          } else {
            targetEmail = '$cleanUsername@ansarfamily.org';
          }
        }
      } catch (e) {
        debugPrint("Username lookup note: $e");
        targetEmail = '$cleanUsername@ansarfamily.org';
      }
    }

    try {
      return await client!.auth.signInWithPassword(
        email: targetEmail,
        password: password,
      );
    } catch (authErr) {
      if (!emailOrUsername.contains('@')) {
        throw AuthException(
          'Unable to sign in with username "$emailOrUsername". '
          'Please verify your password or sign in using your registered email address.',
        );
      }
      rethrow;
    }
  }

  Future<void> signOut() async {
    if (client != null) {
      await client!.auth.signOut();
    }
  }

  // --- PROFILES ---
  Future<ProfileModel?> fetchProfile(String userId) async {
    if (client != null && userId.isNotEmpty) {
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
    return null;
  }

  Future<List<ProfileModel>> fetchPendingProfiles() async {
    if (client != null) {
      try {
        final res =
            await client!.from('profiles').select().eq('status', 'pending');
        return (res as List).map((e) => ProfileModel.fromJson(e)).toList();
      } catch (e) {
        debugPrint("Error fetching pending profiles: $e");
        rethrow;
      }
    }
    return [];
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
    return [];
  }

  Future<bool> updateProfileStatus(String userId, String status) async {
    if (client != null) {
      try {
        final updatedProfile = await client!
            .from('profiles')
            .update({
              'status': status,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', userId)
            .select('id, status')
            .maybeSingle();
        if (updatedProfile == null || updatedProfile['status'] != status) {
          debugPrint(
              "Profile status update did not change $userId to $status.");
          return false;
        }
        return true;
      } catch (e) {
        debugPrint("Error updating status: $e");
        return false;
      }
    }
    return false;
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
    }
    return false;
  }

  // --- FAMILY MEMBERS ---
  Future<List<FamilyMemberModel>> fetchFamilyMembers(String userId) async {
    if (client != null && userId.isNotEmpty) {
      try {
        final res =
            await client!.from('family_members').select().eq('user_id', userId);
        return (res as List).map((e) => FamilyMemberModel.fromJson(e)).toList();
      } catch (e) {
        debugPrint("Error fetching family members: $e");
      }
    }
    return [];
  }

  Future<bool> addFamilyMember({
    required String name,
    required String relation,
    required int age,
  }) async {
    final uId = currentUserId;
    if (client != null && uId.isNotEmpty) {
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
    }
    return false;
  }

  Future<bool> deleteFamilyMember(String id) async {
    if (client != null) {
      try {
        await client!.from('family_members').delete().eq('id', id);
        return true;
      } catch (e) {
        return false;
      }
    }
    return false;
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
    return [];
  }

  Future<bool> createPost(String content) async {
    final uId = currentUserId;
    if (client != null && uId.isNotEmpty) {
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
    }
    return false;
  }

  Future<bool> deletePost(String id) async {
    if (client != null) {
      try {
        await client!.from('posts').delete().eq('id', id);
        return true;
      } catch (e) {
        return false;
      }
    }
    return false;
  }

  // --- MEMBERSHIP FEES & FINANCIALS ---
  Future<List<FeeModel>> fetchUserFees(String userId) async {
    if (client != null && userId.isNotEmpty) {
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
    return [];
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
    return [];
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
    }
    return false;
  }

  Future<bool> updateFeeStatus(String feeId, String status) async {
    if (status != 'paid' && status != 'pending') {
      throw ArgumentError.value(status, 'status', 'Unsupported fee status');
    }

    if (client != null) {
      try {
        final updatedFee = await client!
            .from('membership_fees')
            .update({
              'status': status,
              if (status == 'paid')
                'payment_date': DateTime.now().toIso8601String(),
            })
            .eq('id', feeId)
            .select('id')
            .maybeSingle();
        return updatedFee != null;
      } catch (e) {
        debugPrint("Error updating fee status: $e");
        return false;
      }
    }
    return false;
  }
}
