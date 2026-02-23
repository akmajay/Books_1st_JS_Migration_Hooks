import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import '../../utils/validators.dart';
import '../../widgets/forms/app_text_field.dart';
import '../../widgets/shared/photo_picker.dart';

class BookForm extends StatefulWidget {
  final RecordModel? initialBook;
  final Function(Map<String, dynamic> data, List<dynamic> images) onSubmit;
  final bool isLoading;

  const BookForm({
    super.key,
    this.initialBook,
    required this.onSubmit,
    this.isLoading = false,
  });

  @override
  State<BookForm> createState() => _BookFormState();
}

class _BookFormState extends State<BookForm> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _data = {};
  final List<dynamic> _images = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialBook != null) {
      _data['title'] = widget.initialBook!.getStringValue('title');
      _data['author'] = widget.initialBook!.getStringValue('author');
      _data['selling_price'] = widget.initialBook!.getDoubleValue('selling_price');
      _data['category'] = widget.initialBook!.getStringValue('category');
      _data['condition'] = widget.initialBook!.getStringValue('condition');
      _data['board'] = widget.initialBook!.getStringValue('board');
      _data['class_year'] = widget.initialBook!.getStringValue('class_year');
      _data['stream'] = widget.initialBook!.getStringValue('stream');
      _data['description'] = widget.initialBook!.getStringValue('description');
      
      final photos = widget.initialBook!.getListValue<String>('photos');
      _images.addAll(photos.map((p) => {
        'url': '${widget.initialBook!.collectionId}/${widget.initialBook!.id}/$p',
        'isExisting': true,
      }));
    } else {
      // Set defaults for new book
      _data['status'] = 'active';
      _data['category'] = 'school';
      _data['condition'] = 'good';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          PhotoPicker(
            items: _images,
            onChanged: (newItems) {
              setState(() {
                _images.clear();
                _images.addAll(newItems);
              });
            },
          ),
          const SizedBox(height: 24),
          
          AppTextField(
            label: 'Book Title',
            initialValue: _data['title']?.toString(),
            validator: (v) => AppValidators.required(v, 'Title is required'),
            onSaved: (v) => _data['title'] = v,
          ),
          const SizedBox(height: 16),
          
          AppTextField(
            label: 'Author',
            initialValue: _data['author']?.toString(),
            validator: (v) => AppValidators.required(v, 'Author is required'),
            onSaved: (v) => _data['author'] = v,
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            initialValue: _data['category'],
            decoration: InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            items: const [
              DropdownMenuItem(value: 'school', child: Text('School')),
              DropdownMenuItem(value: 'jee_engineering', child: Text('JEE/Engineering')),
              DropdownMenuItem(value: 'neet_medical', child: Text('NEET/Medical')),
              DropdownMenuItem(value: 'bank_ssc', child: Text('Bank/SSC')),
              DropdownMenuItem(value: 'govt_upsc', child: Text('Govt/UPSC')),
              DropdownMenuItem(value: 'college', child: Text('College')),
              DropdownMenuItem(value: 'other', child: Text('Other')),
            ],
            onChanged: (v) => setState(() => _data['category'] = v),
            validator: (v) => v == null ? 'Category is required' : null,
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _data['condition'],
                  decoration: InputDecoration(
                    labelText: 'Condition',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'like_new', child: Text('Like New')),
                    DropdownMenuItem(value: 'good', child: Text('Good')),
                    DropdownMenuItem(value: 'fair', child: Text('Fair')),
                  ],
                  onChanged: (v) => setState(() => _data['condition'] = v),
                  validator: (v) => v == null ? 'Condition is required' : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppTextField(
                  label: 'Price (₹)',
                  initialValue: _data['selling_price']?.toString(),
                  keyboardType: TextInputType.number,
                  validator: (v) => AppValidators.required(v, 'Price is required'),
                  onSaved: (v) => _data['selling_price'] = double.tryParse(v ?? '0'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _data['board'],
                  decoration: InputDecoration(
                    labelText: 'Board (Optional)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'CBSE', child: Text('CBSE')),
                    DropdownMenuItem(value: 'ICSE', child: Text('ICSE')),
                    DropdownMenuItem(value: 'State Board', child: Text('State Board')),
                    DropdownMenuItem(value: 'IB', child: Text('IB')),
                    DropdownMenuItem(value: 'Other', child: Text('Other')),
                  ],
                  onChanged: (v) => setState(() => _data['board'] = v),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppTextField(
                  label: 'Class/Year',
                  initialValue: _data['class_year']?.toString(),
                  onSaved: (v) => _data['class_year'] = v,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            initialValue: _data['stream'],
            decoration: InputDecoration(
              labelText: 'Stream (Optional)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            items: const [
              DropdownMenuItem(value: 'Science', child: Text('Science')),
              DropdownMenuItem(value: 'Commerce', child: Text('Commerce')),
              DropdownMenuItem(value: 'Arts', child: Text('Arts')),
              DropdownMenuItem(value: 'General', child: Text('General')),
            ],
            onChanged: (v) => setState(() => _data['stream'] = v),
          ),
          const SizedBox(height: 16),

          AppTextField(
            label: 'Description',
            initialValue: _data['description']?.toString(),
            maxLines: 3,
            onSaved: (v) => _data['description'] = v,
          ),

          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: widget.isLoading ? null : () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                // Ensure required enum fields are set if for some reason null
                _data['category'] ??= 'school';
                _data['condition'] ??= 'good';
                widget.onSubmit(_data, _images);
              }
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: widget.isLoading 
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Post Your Listing', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
