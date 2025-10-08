import 'package:flutter/material.dart';
import 'package:peoples_book/api/api.dart';
import 'package:peoples_book/models/persons_details.dart';
import 'package:peoples_book/models/person_detail_page.dart';

class PeopleView extends StatefulWidget {
  const PeopleView({super.key});

  @override
  State<PeopleView> createState() => _PeopleViewState();
}

class _PeopleViewState extends State<PeopleView> {
  // State variables
  List<Results> people = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchPeople();
  }

  /// Fetch people from API
  Future<void> fetchPeople() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    final data = await Api.getPeople(results: 20);

    setState(() {
      isLoading = false;
      if (data != null && data.results != null) {
        people = data.results!;
      } else {
        hasError = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PeopleBook"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchPeople,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  /// Build body based on state
  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Failed to load users'),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: fetchPeople, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (people.isEmpty) {
      return const Center(child: Text('No users found'));
    }

    // Pull-to-refresh ListView
    return RefreshIndicator(
      onRefresh: fetchPeople,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: people.length,
        itemBuilder: (context, index) {
          return PersonCard(
            person: people[index],
            onTap: () {
              // Navigate to detail page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PersonDetailPage(person: people[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Individual Person Card Widget
class PersonCard extends StatelessWidget {
  final Results person;
  final VoidCallback onTap;

  const PersonCard({super.key, required this.person, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Profile Picture
              Hero(
                tag: 'avatar_${person.login?.uuid ?? ''}',
                child: CircleAvatar(
                  radius: 35,
                  backgroundImage: NetworkImage(
                    person.picture?.medium ?? person.picture?.thumbnail ?? '',
                  ),
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  onBackgroundImageError: (_, __) {},
                  child: person.picture?.medium == null
                      ? Icon(
                          Icons.person,
                          size: 35,
                          color: theme.colorScheme.primary,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 16),

              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Full Name
                    Text(
                      '${person.name?.title ?? ''} ${person.name?.first ?? ''} ${person.name?.last ?? ''}'
                          .trim(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Country with flag icon
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${person.location?.city ?? ''}, ${person.location?.country ?? ''}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Age and Gender
                    Row(
                      children: [
                        _buildInfoChip(
                          context,
                          icon: person.gender == 'male'
                              ? Icons.male
                              : Icons.female,
                          label: person.gender?.toUpperCase() ?? '',
                        ),
                        const SizedBox(width: 8),
                        _buildInfoChip(
                          context,
                          icon: Icons.cake,
                          label: '${person.dob?.age ?? 0} yrs',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow icon
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
