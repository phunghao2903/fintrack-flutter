import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:fintrack/features/add_transaction/data/datasource/%20category_remote_datasource.dart';
import 'package:fintrack/features/add_transaction/data/datasource/%20moneysource_remote_datasource.dart';

import 'package:fintrack/features/add_transaction/data/datasource/add_tx_remote_datasource.dart';
import 'package:fintrack/features/add_transaction/data/datasource/image_entry_remote_datasource.dart';
import 'package:fintrack/features/add_transaction/data/datasource/voice_entry_remote_datasource.dart';
import 'package:fintrack/features/add_transaction/data/repository/add_tx_repository_impl.dart';
import 'package:fintrack/features/add_transaction/data/repository/image_entry_repository_impl.dart';
import 'package:fintrack/features/add_transaction/data/repository/voice_entry_repository_impl.dart';
import 'package:fintrack/features/add_transaction/data/repository/category_repository_impl.dart';
import 'package:fintrack/features/add_transaction/data/repository/moneysource_repository_impl.dart';
import 'package:fintrack/features/add_transaction/domain/repositories/%20moneysource_repository.dart';
import 'package:fintrack/features/add_transaction/domain/repositories/image_entry_repository.dart';
import 'package:fintrack/features/add_transaction/domain/repositories/voice_entry_repository.dart';
import 'package:fintrack/features/add_transaction/domain/repositories/category_repository.dart';
import 'package:fintrack/features/add_transaction/domain/usecases/change_money_source_balance_usecase.dart';
import 'package:fintrack/features/add_transaction/domain/usecases/sync_is_income_usecase.dart';
import 'package:fintrack/features/add_transaction/domain/usecases/upload_image_usecase.dart';
import 'package:fintrack/features/add_transaction/domain/usecases/upload_text_usecase.dart';
import 'package:fintrack/features/add_transaction/domain/usecases/upload_voice_usecase.dart';
import 'package:fintrack/features/add_transaction/domain/usecases/get_money_source_by_id_usecase.dart';
import 'package:fintrack/features/add_transaction/domain/usecases/update_budgets_with_transaction_usecase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'domain/repositories/add_tx_repository.dart';
import 'domain/usecases/get_categories_usecase.dart';
import 'domain/usecases/get_money_sources_usecase.dart';
import 'domain/usecases/save_transaction_usecase.dart';
import 'domain/usecases/delete_transaction_usecase.dart';
import 'domain/usecases/update_transaction_usecase.dart';
import 'presentation/bloc/add_tx_bloc.dart';
import 'presentation/bloc/image_entry_bloc.dart';
import 'presentation/bloc/text_entry_bloc.dart';
import 'presentation/bloc/voice_entry_bloc.dart';
import 'presentation/bloc/add_tx_event.dart';
import 'presentation/page/add_transaction_page.dart';
import 'presentation/page/text_transaction_page.dart';
import 'presentation/page/voice_transaction_page.dart';

final sl = GetIt.instance;
const String _addTxWebhookUrl =
    // 'https://n8n-vietnam.id.vn/webhook-test/588768f1-8a5d-4ea2-8f85-94ca49b81f8a';
    'https://n8n-vietnam.id.vn/webhook/588768f1-8a5d-4ea2-8f85-94ca49b81f8a';

Future<void> initAddTransaction() async {
  sl.registerLazySingleton<Dio>(() => Dio());

  // datasources
  sl.registerLazySingleton<AddTxRemoteDataSource>(
    () => AddTxRemoteDataSourceImpl(
      firestore: FirebaseFirestore.instance,
      auth: FirebaseAuth.instance,
    ),
  );
  sl.registerLazySingleton<ImageEntryRemoteDataSource>(
    () => ImageEntryRemoteDataSourceImpl(
      dio: sl(),
      webhookUrl: _addTxWebhookUrl,
      firestore: FirebaseFirestore.instance,
      auth: FirebaseAuth.instance,
    ),
  );
  sl.registerLazySingleton<CategoryRemoteDataSource>(
    () => CategoryRemoteDataSource(
      FirebaseFirestore.instance, // Dùng instance đã có
      // Nếu constructor CategoryRemoteDataSource của bạn không dùng FirebaseAuth, chỉ cần truyền firestore.
    ),
  );

  // Đăng ký CategoryRepository (Sử dụng implementation)
  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(
      sl(),
    ), // sl() sẽ tự động cung cấp CategoryRemoteDataSource đã đăng ký ở trên.
  );

  sl.registerLazySingleton<MoneySourceRemoteDataSource>(
    () => MoneySourceRemoteDataSourceImpl(
      firestore: FirebaseFirestore.instance,
      auth: FirebaseAuth.instance,
    ),
  );

  // Đăng ký MoneySourceRepository
  sl.registerLazySingleton<MoneySourceRepository>(
    // sl() sẽ tự động cung cấp MoneySourceRemoteDataSource
    () => MoneySourceRepositoryImpl(sl()),
  );

  // Đăng ký CategoryRemoteDataSource

  // repository
  sl.registerLazySingleton<AddTxRepository>(() => AddTxRepositoryImpl(sl()));
  sl.registerLazySingleton<ImageEntryRepository>(
    () => ImageEntryRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<VoiceEntryRepository>(
    () => VoiceEntryRepositoryImpl(sl()),
  );

  // usecases

  sl.registerLazySingleton(() => GetCategoriesUsecase(sl()));
  sl.registerLazySingleton(() => GetMoneySourcesUsecase(sl()));
  // sl.registerLazySingleton(() => SaveTransactionUsecase(sl()));
  sl.registerLazySingleton<SaveTransactionUsecase>(
    () => SaveTransactionUsecase(sl()),
  );
  sl.registerLazySingleton<DeleteTransactionUsecase>(
    () => DeleteTransactionUsecase(sl()),
  );
  sl.registerLazySingleton<UpdateTransactionUsecase>(
    () => UpdateTransactionUsecase(sl()),
  );
  sl.registerLazySingleton<ChangeMoneySourceBalanceUsecase>(
    () => ChangeMoneySourceBalanceUsecase(sl()),
  );
  sl.registerLazySingleton<UpdateBudgetsWithTransactionUsecase>(
    () => UpdateBudgetsWithTransactionUsecase(sl()),
  );
  sl.registerLazySingleton<UploadImageUsecase>(() => UploadImageUsecase(sl()));
  sl.registerLazySingleton<UploadTextUsecase>(() => UploadTextUsecase(sl()));
  sl.registerLazySingleton<UploadVoiceUsecase>(() => UploadVoiceUsecase(sl()));
  sl.registerLazySingleton<SyncIsIncomeUseCase>(
    () => SyncIsIncomeUseCase(sl()),
  );
  sl.registerLazySingleton<GetMoneySourceByIdUseCase>(
    () => GetMoneySourceByIdUseCase(sl()),
  );
  // Bloc
  sl.registerFactory<AddTxBloc>(
    () => AddTxBloc(
      getCategories: sl(),
      getMoneySources: sl(),
      saveTx: sl(),
      updateTx: sl(),
      changeBalance: sl(), // 👈 thêm dòng này
      updateBudgets: sl(),
    ),
  );
  sl.registerFactory<ImageEntryBloc>(
    () => ImageEntryBloc(
      uploadImageUsecase: sl(),
      changeMoneySourceBalanceUsecase: sl(),
      syncIsIncomeUseCase: sl(),
      auth: FirebaseAuth.instance,
      updateBudgetsWithTransactionUsecase: sl(),
    ),
  );
  sl.registerFactory<TextEntryBloc>(
    () => TextEntryBloc(
      uploadTextUsecase: sl(),
      getMoneySourcesUsecase: sl(),
      changeMoneySourceBalanceUsecase: sl(),
      updateBudgetsWithTransactionUsecase: sl(),
      syncIsIncomeUseCase: sl(),
      auth: FirebaseAuth.instance,
    ),
  );

  // bloc
  // sl.registerFactory(
  //   () => AddTxBloc(getCategories: sl(), getMoneySources: sl(), saveTx: sl()),
  // );
  // sl.registerFactory(
  //   () => AddTxBloc(getCategories: sl(), getMoneySources: sl(), saveTx: sl(), changeBalance: sl(),),
  // );

  // Ensure voice stack is available even after hot reloads.
  ensureVoiceEntryRegistered();
}

void ensureVoiceEntryRegistered() {
  if (!sl.isRegistered<VoiceEntryRemoteDataSource>()) {
    sl.registerLazySingleton<VoiceEntryRemoteDataSource>(
      () => VoiceEntryRemoteDataSourceImpl(
        dio: sl(),
        webhookUrl: _addTxWebhookUrl,
        firestore: FirebaseFirestore.instance,
        auth: FirebaseAuth.instance,
      ),
    );
  }

  if (!sl.isRegistered<VoiceEntryRepository>()) {
    sl.registerLazySingleton<VoiceEntryRepository>(
      () => VoiceEntryRepositoryImpl(sl()),
    );
  }

  if (!sl.isRegistered<UploadVoiceUsecase>()) {
    sl.registerLazySingleton<UploadVoiceUsecase>(
      () => UploadVoiceUsecase(sl()),
    );
  }

  if (!sl.isRegistered<VoiceEntryBloc>()) {
    sl.registerFactory<VoiceEntryBloc>(
      () => VoiceEntryBloc(
        uploadVoiceUsecase: sl(),
        getMoneySourcesUsecase: sl(),
        changeMoneySourceBalanceUsecase: sl(),
        updateBudgetsWithTransactionUsecase: sl(),
        syncIsIncomeUseCase: sl(),
        auth: FirebaseAuth.instance,
      ),
    );
  }
}

Widget buildAddTransactionPage() {
  return MultiBlocProvider(
    providers: [
      BlocProvider<AddTxBloc>(
        create: (_) => sl<AddTxBloc>()..add(AddTxInitEvent()),
      ),
      BlocProvider<ImageEntryBloc>(create: (_) => sl<ImageEntryBloc>()),
    ],
    child: const AddTransactionPage(),
  );
}

Widget buildTextTransactionPage() {
  return BlocProvider<TextEntryBloc>(
    create: (_) => sl<TextEntryBloc>(),
    child: const TextTransactionPage(),
  );
}

Widget buildVoiceTransactionPage() {
  ensureVoiceEntryRegistered();
  return BlocProvider<VoiceEntryBloc>(
    create: (_) => sl<VoiceEntryBloc>(),
    child: const VoiceTransactionPage(),
  );
}
