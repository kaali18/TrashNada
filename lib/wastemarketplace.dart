import 'package:flutter/material.dart';
import 'package:abwm/Services/api_services.dart';
import 'package:abwm/models/waste_models.dart';

class WasteItemsScreen extends StatefulWidget {
  @override
  _WasteItemsScreenState createState() => _WasteItemsScreenState();
}

class _WasteItemsScreenState extends State<WasteItemsScreen> {
  List<Waste> _wasteItems = [];

  @override
  void initState() {
    super.initState();
    _fetchWasteItems();
  }

  Future<void> _fetchWasteItems() async {
    try {
      final wasteItems = await ApiService.getWasteItems();
      setState(() {
        _wasteItems = wasteItems;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch waste items: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Waste Items'),
      ),
      body: ListView.builder(
        itemCount: _wasteItems.length,
        itemBuilder: (context, index) {
          final waste = _wasteItems[index];
          return ListTile(
            title: Text('${waste.type} - ${waste.quantity} kg'),
            subtitle: Text('Price: \$${waste.price}/kg | Location: ${waste.location}'),
            trailing: ElevatedButton(
              onPressed: () async {
                try {
                  await ApiService.purchaseWaste(waste.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Waste purchased successfully!')),
                  );
                  _fetchWasteItems(); // Refresh the list
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to purchase waste: $e')),
                  );
                }
              },
              child: Text('Purchase'),
            ),
          );
        },
      ),
    );
  }
}