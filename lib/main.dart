import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const KarsaatApp());

class Job {
  final String title, category, city, description, date, time;
  final int wage, hours;
  Job({required this.title, required this.category, required this.city,
    required this.description, required this.date, required this.time,
    required this.wage, required this.hours});
  Map<String,dynamic> toJson()=>{'title':title,'category':category,'city':city,
    'description':description,'date':date,'time':time,'wage':wage,'hours':hours};
  factory Job.fromJson(Map<String,dynamic> j)=>Job(title:j['title'],category:j['category'],
    city:j['city'],description:j['description'],date:j['date'],time:j['time'],
    wage:j['wage'],hours:j['hours']);
}

class KarsaatApp extends StatelessWidget {
  const KarsaatApp({super.key});
  @override Widget build(BuildContext c)=>MaterialApp(
    debugShowCheckedModeBanner:false, title:'کارساعت', locale:const Locale('fa'),
    theme:ThemeData(useMaterial3:true,fontFamily:'sans',colorSchemeSeed:Colors.indigo,
      scaffoldBackgroundColor:const Color(0xfff6f7fb)),
    home:const HomePage());
}

class HomePage extends StatefulWidget { const HomePage({super.key}); @override State<HomePage> createState()=>_HomePageState(); }
class _HomePageState extends State<HomePage>{
  int tab=0; String query=''; List<Job> jobs=[];
  @override void initState(){super.initState(); load();}
  Future<void> load() async{
    final p=await SharedPreferences.getInstance(); final raw=p.getString('jobs');
    if(raw!=null){jobs=(jsonDecode(raw) as List).map((x)=>Job.fromJson(x)).toList();}
    else {jobs=[
      Job(title:'نیروی بسته‌بندی',category:'بسته‌بندی',city:'اسلامشهر',description:'کمک در بسته‌بندی محصولات در یک شیفت کوتاه.',date:'امروز',time:'۱۴:۰۰ تا ۱۸:۰۰',wage:180000,hours:4),
      Job(title:'کمک‌کار جابه‌جایی',category:'خدمات',city:'تهران',description:'جابه‌جایی چند وسیله داخل ساختمان. کار سبک و کوتاه.',date:'فردا',time:'۱۰:۰۰ تا ۱۴:۰۰',wage:220000,hours:4),
      Job(title:'نیروی فروش موقت',category:'فروش',city:'رباط‌کریم',description:'کمک به فروش در یک فروشگاه برای شیفت عصر.',date:'جمعه',time:'۱۶:۰۰ تا ۲۱:۰۰',wage:200000,hours:5),
    ]; await save();}
    setState((){});
  }
  Future<void> save() async{final p=await SharedPreferences.getInstance(); await p.setString('jobs',jsonEncode(jobs.map((x)=>x.toJson()).toList()));}
  @override Widget build(BuildContext c)=>Directionality(textDirection:TextDirection.rtl,child:Scaffold(
    appBar:AppBar(title:const Text('کارساعت',style:TextStyle(fontWeight:FontWeight.w800)),centerTitle:false,
      actions:[IconButton(onPressed:()=>showSearch(context:context,delegate:JobSearch(jobs)),icon:const Icon(Icons.search))]),
    body:tab==0?_home():tab==1?_requests():const Profile(),
    bottomNavigationBar:NavigationBar(selectedIndex:tab,onDestinationSelected:(i)=>setState(()=>tab=i),
      destinations:const [NavigationDestination(icon:Icon(Icons.home_outlined),selectedIcon:Icon(Icons.home),label:'خانه'),
      NavigationDestination(icon:Icon(Icons.assignment_outlined),selectedIcon:Icon(Icons.assignment),label:'درخواست‌ها'),
      NavigationDestination(icon:Icon(Icons.person_outline),selectedIcon:Icon(Icons.person),label:'پروفایل')]),
    floatingActionButton:tab==0?FloatingActionButton.extended(onPressed:()=>addJob(),icon:const Icon(Icons.add),label:const Text('ثبت کار')):null));
  Widget _home(){
    final list=jobs.where((j)=>query.isEmpty||('${j.title} ${j.category} ${j.city}').contains(query)).toList();
    return ListView(padding:const EdgeInsets.all(16),children:[
      Container(padding:const EdgeInsets.all(20),decoration:BoxDecoration(borderRadius:BorderRadius.circular(24),
        gradient:const LinearGradient(colors:[Color(0xff2637a8),Color(0xff5668e8)])),
        child:const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text('کار نزدیکته، درآمد نزدیکته.',style:TextStyle(color:Colors.white,fontSize:23,fontWeight:FontWeight.bold)),
          SizedBox(height:8),Text('کارهای ساعتی اطراف خودت را پیدا کن یا نیروی موردنیازت را پیدا کن.',style:TextStyle(color:Colors.white70,fontSize:14))]),
      const SizedBox(height:18), const Text('کارهای پیشنهادی',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold)),
      const SizedBox(height:10), ...list.map((j)=>JobCard(job:j,onTap:()=>showDetail(j)))]);
  }
  void showDetail(Job j)=>showModalBottomSheet(context:context,isScrollControlled:true,showDragHandle:true,
    builder:(_)=>Directionality(textDirection:TextDirection.rtl,child:Padding(padding:const EdgeInsets.fromLTRB(20,8,20,30),
      child:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text(j.title,style:const TextStyle(fontSize:24,fontWeight:FontWeight.bold)),Text('${j.category} • ${j.city}',style:const TextStyle(color:Colors.grey)),
        const SizedBox(height:18),Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[
          _info(Icons.payments_outlined,'${j.wage.toString()} تومان / ساعت'),_info(Icons.schedule,'${j.hours} ساعت')]),
        const SizedBox(height:12),Text('${j.date} • ${j.time}'),const SizedBox(height:16),Text(j.description),
        const SizedBox(height:22),SizedBox(width:double.infinity,child:FilledButton.icon(onPressed:(){Navigator.pop(context);ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('درخواست شما ثبت شد.')));},
          icon:const Icon(Icons.send),label:const Text('درخواست انجام کار')))])));
  Widget _info(IconData i,String t)=>Row(children:[Icon(i,size:20),const SizedBox(width:5),Text(t)]);
  Future<void> addJob() async{
    final title=TextEditingController(), city=TextEditingController(text:'اسلامشهر'), wage=TextEditingController(text:'200000');
    final desc=TextEditingController(); String cat='خدمات';
    final ok=await showDialog<bool>(context:context,builder:(_)=>Directionality(textDirection:TextDirection.rtl,child:AlertDialog(
      title:const Text('ثبت کار ساعتی'),content:SizedBox(width:420,child:SingleChildScrollView(child:Column(children:[
        TextField(controller:title,decoration:const InputDecoration(labelText:'عنوان کار')),
        TextField(controller:city,decoration:const InputDecoration(labelText:'شهر / محدوده')),
        DropdownButtonFormField<String>(value:cat,decoration:const InputDecoration(labelText:'دسته‌بندی'),
          items:['خدمات','فروش','بسته‌بندی','پیک','فنی','سایر'].map((x)=>DropdownMenuItem(value:x,child:Text(x))).toList(),onChanged:(x)=>cat=x!),
        TextField(controller:wage,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'دستمزد ساعتی (تومان)')),
        TextField(controller:desc,maxLines:3,decoration:const InputDecoration(labelText:'توضیحات'))])),
      actions:[TextButton(onPressed:()=>Navigator.pop(context,false),child:const Text('انصراف')),FilledButton(onPressed:()=>Navigator.pop(context,true),child:const Text('ثبت'))])));
    if(ok==true && title.text.trim().isNotEmpty){jobs.insert(0,Job(title:title.text,category:cat,city:city.text,description:desc.text,date:'امروز',time:'توافقی',wage:int.tryParse(wage.text.replaceAll(',',''))??0,hours:0));await save();setState((){});}
  }
  Widget _requests()=>const Center(child:Column(mainAxisSize:MainAxisSize.min,children:[Icon(Icons.inbox_outlined,size:60,color:Colors.grey),SizedBox(height:10),Text('هنوز درخواستی ثبت نشده')]));
}

class JobCard extends StatelessWidget{
 final Job job; final VoidCallback onTap; const JobCard({super.key,required this.job,required this.onTap});
 @override Widget build(BuildContext c)=>Card(margin:const EdgeInsets.only(bottom:12),child:InkWell(onTap:onTap,borderRadius:BorderRadius.circular(18),
  child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
   Row(children:[Container(padding:const EdgeInsets.all(10),decoration:BoxDecoration(color:Theme.of(c).colorScheme.primaryContainer,borderRadius:BorderRadius.circular(14)),child:const Icon(Icons.work_outline)),
   const SizedBox(width:12),Expanded(child:Text(job.title,style:const TextStyle(fontSize:17,fontWeight:FontWeight.bold))),Text('${job.wage} تومان',style:TextStyle(fontWeight:FontWeight.bold,color:Theme.of(c).colorScheme.primary))]),
   const SizedBox(height:12),Text('${job.category}  •  ${job.city}  •  ${job.date}',style:const TextStyle(color:Colors.grey)),const SizedBox(height:8),
   Row(children:[const Icon(Icons.schedule,size:17),const SizedBox(width:5),Text(job.time),const Spacer(),const Icon(Icons.chevron_left)])])));
}

class JobSearch extends SearchDelegate<Job?>{
 final List<Job> jobs; JobSearch(this.jobs);
 @override List<Widget>? buildActions(BuildContext c)=>[IconButton(onPressed:()=>query='',icon:const Icon(Icons.clear))];
 @override Widget? buildLeading(BuildContext c)=>IconButton(onPressed:()=>close(c,null),icon:const Icon(Icons.arrow_back));
 @override Widget buildResults(BuildContext c)=>Directionality(textDirection:TextDirection.rtl,child:ListView(padding:const EdgeInsets.all(12),children:jobs.where((j)=>('${j.title} ${j.city} ${j.category}').contains(query)).map((j)=>JobCard(job:j,onTap:()=>close(c,j))).toList());
 @override Widget buildSuggestions(BuildContext c)=>buildResults(c);
}
class Profile extends StatelessWidget{
 const Profile({super.key});
 @override Widget build(BuildContext c)=>Directionality(textDirection:TextDirection.rtl,child:ListView(padding:const EdgeInsets.all(18),children:[
  const CircleAvatar(radius:42,child:Icon(Icons.person,size:45)),const SizedBox(height:12),const Center(child:Text('کاربر کارساعت',style:TextStyle(fontSize:22,fontWeight:FontWeight.bold))),
  const SizedBox(height:22),Card(child:Column(children:[
   ListTile(leading:const Icon(Icons.badge_outlined),title:const Text('نوع حساب'),subtitle:const Text('کارجو / کارفرما')),
   ListTile(leading:const Icon(Icons.location_on_outlined),title:const Text('محدوده فعالیت'),subtitle:const Text('اسلامشهر و تهران')),
   ListTile(leading:const Icon(Icons.star_outline),title:const Text('امتیاز'),subtitle:const Text('هنوز امتیازی ثبت نشده'))]))]));
}
