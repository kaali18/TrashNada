import 'package:flutter/material.dart';
import 'package:abwm/Services/api_services.dart';
//import 'dart:convert';

class ApprovalScreen extends StatefulWidget {
  @override
  _ApprovalScreenState createState() => _ApprovalScreenState();
}

class _ApprovalScreenState extends State<ApprovalScreen> {
  List<Map<String, dynamic>> _requests = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
  setState(() {
    _isLoading = true;
    _hasError = false;
  });
  try {
    final requests = await ApiService.getPendingRequests();
    //print('Fetched requests:', requests);
    setState(() {
      _requests = requests;
      _isLoading = false;
    });
  } catch (e) {
    print('Error fetching requests: $e');
    setState(() {
      _hasError = true;
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to load requests: $e')),
    );
  }
}

 Future<void> _approveRequest(String wasteId, String requestId) async {
  try {
    await ApiService.approvePurchase(wasteId, requestId, 'approved');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Request approved successfully!')),
    );
    await _fetchRequests(); // Refresh the list
  } catch (e) {
    print('Error approving request: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to approve request: $e')),
    );
  }
}

  Future<void> _rejectRequest(String wasteId, String requestId) async {
    try {
      await ApiService.approvePurchase(wasteId, requestId, 'rejected');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request rejected successfully!')),
      );
      await _fetchRequests();
    } catch (e) {
      print('Error rejecting request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to reject request: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Approval Requests'),
        backgroundColor: Colors.green.shade700,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.green.shade800, Colors.green.shade200],
          ),
        ),
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: Colors.white))
            : _hasError
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Failed to load requests. Tap to retry.',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _fetchRequests,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            foregroundColor: Colors.white,
                          ),
                          child: Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : _requests.isEmpty
                    ? Center(
                        child: Text(
                          'No pending requests.',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(16.0),
                        itemCount: _requests.length,
                        itemBuilder: (context, index) {
                          final request = _requests[index];
                          return Card(
                            elevation: 4,
                            margin: EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            color: Colors.green.shade600.withOpacity(0.2),
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Waste Type: ${request['wasteType'] ?? 'Unknown'}',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    'Quantity: ${request['wasteQuantity'] ?? 0} kg',
                                    style: TextStyle(color: Colors.white70, fontSize: 14),
                                  ),
                                  Text(
                                    'Price: \$${request['wastePrice']?.toStringAsFixed(2) ?? '0.00'} per kg',
                                    style: TextStyle(color: Colors.white70, fontSize: 14),
                                  ),
                                  Text(
                                    'Location: ${request['wasteLocation'] ?? 'Unknown'}',
                                    style: TextStyle(color: Colors.white70, fontSize: 14),
                                  ),
                                  Text(
                                    'Requested By: ${request['buyerId'] ?? 'Anonymous'}',
                                    style: TextStyle(color: Colors.white70, fontSize: 14),
                                  ),
                                  Text(
                                    'Uploaded By: ${request['uploadedBy'] ?? 'Anonymous'}', // Added for clarity
                                    style: TextStyle(color: Colors.white70, fontSize: 14),
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () => _approveRequest(
                                            request['wasteId'], request['_id']),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green.shade700,
                                          foregroundColor: Colors.white,
                                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8)),
                                        ),
                                        child: Text('Approve'),
                                      ),
                                      SizedBox(width: 10),
                                      ElevatedButton(
                                        onPressed: () => _rejectRequest(
                                            request['wasteId'], request['_id']),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red.shade700,
                                          foregroundColor: Colors.white,
                                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8)),
                                        ),
                                        child: Text('Reject'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}