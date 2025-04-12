class AccountScreen extends ConsumerWidget { 
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
      ),
      body: Center(
        child: Text('Account Screen'),
      ),
    );
  }
}