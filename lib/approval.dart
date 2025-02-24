import 'package:flutter/material.dart';
import 'package:abwm/Services/api_services.dart';
import 'package:abwm/models/waste_models.dart';

class ApprovalScreen extends StatefulWidget {
  @override
  _ApprovalScreenState createState() => _ApprovalScreenState();
}

class _ApprovalScreenState extends State<ApprovalScreen> {
  List<Waste> _pendingRequests = [];

  @override
  void initState() {
    super.initState();
    _fetchPendingRequests();
  }

  Future<void> _fetchPendingRequests() async {
    try {
      final requests = await ApiService.getPendingRequests();
      setState(() => _pendingRequests = requests);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch requests: $e')),
      );
    }
  }

  Future<void> _handleRequest(String wasteId, String requestId, String status) async {
    try {
      await ApiService.approvePurchase(wasteId, requestId, status);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request $status!')),
      );
      _fetchPendingRequests();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to process request: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pending Approvals'), backgroundColor: Colors.green.shade700),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.green.shade800, Colors.green.shade200],
          ),
        ),
        child: _pendingRequests.isEmpty
            ? Center(child: Text('No pending requests'))
            : ListView.builder(
                itemCount: _pendingRequests.length,
                itemBuilder: (context, index) {
                  final waste = _pendingRequests[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    elevation: 4,
                    child: ExpansionTile(
                      title: Text('${waste.type} - ${waste.quantity} kg'),
                      subtitle: Text('Price: \$${waste.price}/kg | Location: ${waste.location}'),
                      children: waste.purchaseRequests.map((request) {
                        return ListTile(
                          title: Text('Request from: ${request.userId}'),
                          subtitle: Text('Status: ${request.status}'),
                          trailing: request.status == 'pending'
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.check, color: Colors.green),
                                      onPressed: () => _handleRequest(waste.id!, request.id!, 'approved'),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.close, color: Colors.red),
                                      onPressed: () => _handleRequest(waste.id!, request.id!, 'rejected'),
                                    ),
                                  ],
                                )
                              : null,
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
      ),
    );
  }
}