import 'package:flutter/material.dart';

class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonLoader({
    super.key,
    this.width = double.infinity,
    this.height = 20,
    this.borderRadius = 8,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 102, end: 204).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            color: isDark
                ? Colors.grey[800]!.withAlpha(_animation.value.toInt())
                : Colors.grey[300]!.withAlpha(_animation.value.toInt()),
          ),
        );
      },
    );
  }
}

/// Skeleton untuk Avatar/Profile Image
class SkeletonAvatar extends StatelessWidget {
  final double size;

  const SkeletonAvatar({super.key, this.size = 80});

  @override
  Widget build(BuildContext context) {
    return SkeletonLoader(
      width: size,
      height: size,
      borderRadius: size / 2,
    );
  }
}

/// Skeleton untuk Card
class SkeletonCard extends StatelessWidget {
  final double height;
  final EdgeInsets? margin;

  const SkeletonCard({
    super.key,
    this.height = 100,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SkeletonLoader(
        height: height,
        borderRadius: 12,
      ),
    );
  }
}

/// Skeleton untuk Profile Page
class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black87 : Colors.white,
      body: CustomScrollView(
        slivers: [
          // Skeleton AppBar
          SliverAppBar(
            expandedHeight: 180,
            backgroundColor: const Color.fromRGBO(21, 116, 42, 1),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: const Color.fromRGBO(21, 116, 42, 1),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      // Avatar skeleton
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withAlpha(77),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Name skeleton
                      Container(
                        width: 120,
                        height: 20,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.white.withAlpha(77),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Content skeleton
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats card skeleton
                  const SkeletonCard(height: 80),
                  const SizedBox(height: 16),

                  // Activity section skeleton
                  const SkeletonCard(height: 50),
                  const SizedBox(height: 24),

                  // Info section skeleton
                  _buildSectionSkeleton('Info Pribadi'),
                  const SkeletonCard(height: 120),
                  const SizedBox(height: 24),

                  // Settings skeleton
                  _buildSectionSkeleton('Pengaturan'),
                  const SkeletonCard(height: 60),
                  const SizedBox(height: 24),

                  // Logout button skeleton
                  const SkeletonLoader(height: 50, borderRadius: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionSkeleton(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SkeletonLoader(width: 100, height: 16),
    );
  }
}

/// Skeleton untuk Login/Register form
class AuthFormSkeleton extends StatelessWidget {
  const AuthFormSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SkeletonLoader(height: 48, borderRadius: 12),
        const SizedBox(height: 12),
        const SkeletonLoader(height: 48, borderRadius: 12),
        const SizedBox(height: 12),
        const SkeletonLoader(height: 48, borderRadius: 12),
        const SizedBox(height: 24),
        const SkeletonLoader(height: 48, borderRadius: 12),
      ],
    );
  }
}
