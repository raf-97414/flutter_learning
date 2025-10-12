import 'package:flutter/material.dart';
import 'package:peoples_book/model/peoples_details.dart';
import 'package:intl/intl.dart';

class PersonDetailPage extends StatelessWidget {
  final Results person;

  const PersonDetailPage({super.key, required this.person});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share feature coming soon!')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with profile picture
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  // Profile Picture
                  Hero(
                    tag: 'avatar_${person.login?.uuid ?? ''}',
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: NetworkImage(
                        person.picture?.large ?? person.picture?.medium ?? '',
                      ),
                      backgroundColor: Colors.white,
                      child: person.picture?.large == null
                          ? const Icon(Icons.person, size: 60, color: Colors.grey)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Name
                  Text(
                    '${person.name?.title ?? ''} ${person.name?.first ?? ''} ${person.name?.last ?? ''}'.trim(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  
                  // Username
                  Text(
                    '@${person.login?.username ?? 'unknown'}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),

            // Details Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Personal Information Section
                  _buildSectionTitle(context, 'Personal Information'),
                  _buildDetailCard(
                    context,
                    children: [
                      _buildDetailRow(
                        context,
                        icon: Icons.cake,
                        label: 'Age',
                        value: '${person.dob?.age ?? 0} years old',
                      ),
                      _buildDetailRow(
                        context,
                        icon: person.gender == 'male' ? Icons.male : Icons.female,
                        label: 'Gender',
                        value: person.gender?.toUpperCase() ?? 'N/A',
                      ),
                      _buildDetailRow(
                        context,
                        icon: Icons.calendar_today,
                        label: 'Date of Birth',
                        value: _formatDate(person.dob?.date),
                      ),
                      _buildDetailRow(
                        context,
                        icon: Icons.flag,
                        label: 'Nationality',
                        value: person.nat ?? 'N/A',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Contact Information Section
                  _buildSectionTitle(context, 'Contact Information'),
                  _buildDetailCard(
                    context,
                    children: [
                      _buildDetailRow(
                        context,
                        icon: Icons.email,
                        label: 'Email',
                        value: person.email ?? 'N/A',
                      ),
                      _buildDetailRow(
                        context,
                        icon: Icons.phone,
                        label: 'Phone',
                        value: person.phone ?? 'N/A',
                      ),
                      _buildDetailRow(
                        context,
                        icon: Icons.smartphone,
                        label: 'Cell',
                        value: person.cell ?? 'N/A',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Location Section
                  _buildSectionTitle(context, 'Location'),
                  _buildDetailCard(
                    context,
                    children: [
                      _buildDetailRow(
                        context,
                        icon: Icons.home,
                        label: 'Street',
                        value: '${person.location?.street?.number ?? ''} ${person.location?.street?.name ?? ''}'.trim(),
                      ),
                      _buildDetailRow(
                        context,
                        icon: Icons.location_city,
                        label: 'City',
                        value: person.location?.city ?? 'N/A',
                      ),
                      _buildDetailRow(
                        context,
                        icon: Icons.map,
                        label: 'State',
                        value: person.location?.state ?? 'N/A',
                      ),
                      _buildDetailRow(
                        context,
                        icon: Icons.public,
                        label: 'Country',
                        value: person.location?.country ?? 'N/A',
                      ),
                      _buildDetailRow(
                        context,
                        icon: Icons.markunread_mailbox,
                        label: 'Postcode',
                        value: person.location?.postcode?.toString() ?? 'N/A',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Account Information Section
                  _buildSectionTitle(context, 'Account Information'),
                  _buildDetailCard(
                    context,
                    children: [
                      _buildDetailRow(
                        context,
                        icon: Icons.account_circle,
                        label: 'Username',
                        value: person.login?.username ?? 'N/A',
                      ),
                      _buildDetailRow(
                        context,
                        icon: Icons.fingerprint,
                        label: 'UUID',
                        value: person.login?.uuid ?? 'N/A',
                      ),
                      _buildDetailRow(
                        context,
                        icon: Icons.event,
                        label: 'Registered',
                        value: _formatDate(person.registered?.date),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDetailCard(BuildContext context, {required List<Widget> children}) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }
}