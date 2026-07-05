import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user_profile.dart';
import '../../providers/user_provider.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() =>
      _UserListScreenState();
}

class _UserListScreenState
    extends State<UserListScreen> {

  final TextEditingController _searchController =
      TextEditingController();

  List<UserProfile> _filteredUsers = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {

      final provider =
          context.read<UserProvider>();

      await provider.loadUsers();

      setState(() {
        _filteredUsers =
            List.from(provider.users);
      });

    });

    _searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterUsers() {

    final provider =
        context.read<UserProvider>();

    final query =
        _searchController.text
            .toLowerCase()
            .trim();

    setState(() {

      if (query.isEmpty) {

        _filteredUsers =
            List.from(provider.users);

      } else {

        _filteredUsers = provider.users.where((user) {

          return user.name
                  .toLowerCase()
                  .contains(query) ||
              user.email
                  .toLowerCase()
                  .contains(query);

        }).toList();

      }

    });
  }

  Future<void> _refreshUsers() async {

    final provider =
        context.read<UserProvider>();

    await provider.loadUsers();

    _filterUsers();

  }

  Future<void> _changeRole(UserProfile user) async {

  final provider =
      context.read<UserProvider>();

  final newRole =
      user.role == 'admin'
          ? 'client'
          : 'admin';

  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Cambiar rol"),
        content: Text(
          "¿Desea cambiar el rol de ${user.name} a "
          "${newRole == 'admin' ? 'Administrador' : 'Cliente'}?",
        ),
        actions: [

          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text("Cancelar"),
          ),

          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text("Aceptar"),
          ),

        ],
      );
    },
  );

  if (confirm != true) return;

  final error =
      await provider.updateRole(
    user.uid,
    newRole,
  );

  if (!mounted) return;

  if (error == null) {

    await _refreshUsers();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content:
            Text("Rol actualizado correctamente"),
      ),
    );

  } else {

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
      ),
    );

  }

}


Future<void> _changeBlocked(
    UserProfile user) async {

  final provider =
      context.read<UserProvider>();

  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) {

      return AlertDialog(

        title: Text(
          user.blocked
              ? "Desbloquear usuario"
              : "Bloquear usuario",
        ),

        content: Text(
          user.blocked
              ? "¿Desea desbloquear a ${user.name}?"
              : "¿Desea bloquear a ${user.name}?",
        ),

        actions: [

          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text("Cancelar"),
          ),

          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text("Aceptar"),
          ),

        ],
      );

    },
  );

  if (confirm != true) return;

  final error =
      await provider.updateBlocked(
    user.uid,
    !user.blocked,
  );

  if (!mounted) return;

  if (error == null) {

    await _refreshUsers();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          user.blocked
              ? "Usuario desbloqueado"
              : "Usuario bloqueado",
        ),
      ),
    );

  } else {

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
      ),
    );

  }

}



  @override
  Widget build(BuildContext context) {

    final provider =
        context.watch<UserProvider>();

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "Usuarios registrados",
        ),
        centerTitle: true,
      ),

      body: RefreshIndicator(
  onRefresh: _refreshUsers,
  child: Column(
    children: [

      Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: "Buscar por nombre o correo",
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(12),
            ),
          ),
        ),
      ),

      Expanded(
        child: provider.isLoading
            ? const Center(
                child:
                    CircularProgressIndicator(),
              )
            : _filteredUsers.isEmpty
                ? const Center(
                    child: Text(
                      "No existen usuarios",
                    ),
                  )
                : ListView.builder(
                    padding:
                        const EdgeInsets.only(
                      bottom: 15,
                    ),
                    itemCount:
                        _filteredUsers.length,
                    itemBuilder:
                        (context, index) {

                      final user =
                          _filteredUsers[index];

                      return Card(
                        margin:
                            const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        elevation: 3,
                        child: ListTile(

                          leading: CircleAvatar(
                            radius: 25,
                            child: Text(
                              user.name
                                  .substring(0, 1)
                                  .toUpperCase(),
                            ),
                          ),

                          title: Text(
                            user.name,
                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          subtitle: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [

                              const SizedBox(
                                  height: 5),

                              Text(user.email),

                              const SizedBox(
                                  height: 5),

                              Row(
                                children: [

                                  const Icon(
                                    Icons.admin_panel_settings,
                                    size: 18,
                                  ),

                                  const SizedBox(
                                      width: 5),

                                  Text(
                                    user.role ==
                                            'admin'
                                        ? 'Administrador'
                                        : 'Cliente',
                                  ),
                                ],
                              ),

                              const SizedBox(
                                  height: 5),

                              Row(
                                children: [

                                  Icon(
                                    user.blocked
                                        ? Icons.block
                                        : Icons.check_circle,
                                    size: 18,
                                    color: user
                                            .blocked
                                        ? Colors.red
                                        : Colors.green,
                                  ),

                                  const SizedBox(
                                      width: 5),

                                  Text(
                                    user.blocked
                                        ? "Bloqueado"
                                        : "Activo",
                                  ),

                                ],
                              ),

                            ],
                          ),

                          trailing:
                              PopupMenuButton<String>(

                            onSelected:
                                (value) {

                              switch (value) {

                                case 'role':
                                  _changeRole(user);
                                  break;

                                case 'block':
                                  _changeBlocked(
                                      user);
                                  break;

                                case 'profile':
                                  Navigator.pushNamed(
                                    context,
                                    '/profile',
                                    arguments: user,
                                  );
                                  break;

                              }

                            },

                            itemBuilder:
                                (context) => [

                              const PopupMenuItem(
                                value: 'role',
                                child: Text(
                                  'Cambiar rol',
                                ),
                              ),

                              PopupMenuItem(
                                value: 'block',
                                child: Text(
                                  user.blocked
                                      ? 'Desbloquear'
                                      : 'Bloquear',
                                ),
                              ),

                              const PopupMenuItem(
                                value: 'profile',
                                child: Text(
                                  'Ver perfil',
                                ),
                              ),

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