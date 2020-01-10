import 'package:http/http.dart' show Client;

import 'package:kilat/app/blocs/account_bloc.dart';
import 'package:kilat/app/blocs/activity_bloc.dart';
import 'package:kilat/app/blocs/bloc.dart';
import 'package:kilat/app/blocs/busy_bloc.dart';
import 'package:kilat/app/blocs/category_bloc.dart';
import 'package:kilat/app/blocs/event_bloc.dart';
import 'package:kilat/app/blocs/task_bloc.dart';
import 'package:kilat/app/networks/account_provider.dart';
import 'package:kilat/app/networks/account_repository.dart';
import 'package:kilat/app/networks/busy_provider.dart';
import 'package:kilat/app/networks/busy_repository.dart';
import 'package:kilat/app/networks/category_provider.dart';
import 'package:kilat/app/networks/category_repository.dart';
import 'package:kilat/app/networks/event_provider.dart';
import 'package:kilat/app/networks/event_repository.dart';
import 'package:kilat/app/networks/task_provider.dart';
import 'package:kilat/app/networks/task_repository.dart';

Client client = Client();

AccountProvider accountProvider = AccountProvider(client);
BusyProvider busyProvider = BusyProvider(client);
CategoryProvider categoryProvider = CategoryProvider(client);
EventProvider eventProvider = EventProvider(client);
TaskProvider taskProvider = TaskProvider(client);

AccountRepository accountRepository = AccountRepository(accountProvider);
BusyRepository busyRepository = BusyRepository(busyProvider);
CategoryRepository categoryRepository = CategoryRepository(categoryProvider);
EventRepository eventRepository = EventRepository(eventProvider);
TaskRepository taskRepository = TaskRepository(taskProvider);

Bloc accountBloc = AccountBloc(accountRepository);
Bloc activityBloc = ActivityBloc(busyBloc, eventBloc, taskBloc);
Bloc busyBloc = BusyBloc(busyRepository);
Bloc categoryBloc = CategoryBloc(categoryRepository);
Bloc eventBloc = EventBloc(eventRepository);
Bloc taskBloc = TaskBloc(taskRepository);
