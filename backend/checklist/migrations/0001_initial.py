# Generated by Django 4.0.10 on 2024-03-17 14:48

from django.conf import settings
import django.core.validators
from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    initial = True

    dependencies = [
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
        ('companies', '0001_initial'),
    ]

    operations = [
        migrations.CreateModel(
            name='Checklist',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                ('name', models.TextField()),
                ('start_date', models.DateField(blank=True, null=True)),
                ('timezone', models.CharField(default='Asia/Almaty', max_length=64)),
                ('executor_reward', models.PositiveIntegerField(default=0)),
                ('executor_penalty_late', models.PositiveIntegerField(default=0)),
                ('executor_penalty_not_completed', models.PositiveIntegerField(default=0)),
                ('inspector_reward', models.PositiveIntegerField(default=0)),
                ('inspector_penalty_late', models.PositiveIntegerField(default=0)),
                ('inspector_penalty_not_completed', models.PositiveIntegerField(default=0)),
                ('company', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='checklists', to='companies.company')),
                ('department', models.ForeignKey(null=True, on_delete=django.db.models.deletion.SET_NULL, related_name='checklists', to='companies.department')),
            ],
            options={
                'abstract': False,
            },
        ),
        migrations.CreateModel(
            name='File',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                ('file_name', models.TextField()),
                ('file_size', models.PositiveBigIntegerField(help_text='File size in bytes')),
                ('local_file', models.FileField(blank=True, null=True, upload_to='files/')),
                ('s3_url', models.TextField(blank=True)),
                ('uploaded_by', models.ForeignKey(null=True, on_delete=django.db.models.deletion.SET_NULL, related_name='files', to=settings.AUTH_USER_MODEL)),
            ],
            options={
                'abstract': False,
            },
        ),
        migrations.CreateModel(
            name='Task',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                ('name', models.TextField()),
            ],
            options={
                'abstract': False,
            },
        ),
        migrations.CreateModel(
            name='TaskGroup',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                ('name', models.TextField()),
                ('checkbox', models.BooleanField(default=False)),
                ('checklist', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='groups', to='checklist.checklist')),
            ],
            options={
                'abstract': False,
            },
        ),
        migrations.CreateModel(
            name='TaskFile',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                ('file', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='task_files', to='checklist.file')),
                ('task', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='files', to='checklist.task')),
            ],
            options={
                'abstract': False,
            },
        ),
        migrations.CreateModel(
            name='TaskCheck',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                ('date', models.DateField()),
                ('task', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='checklist.task')),
                ('user', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to=settings.AUTH_USER_MODEL)),
            ],
            options={
                'abstract': False,
            },
        ),
        migrations.AddField(
            model_name='task',
            name='group',
            field=models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='tasks', to='checklist.taskgroup'),
        ),
        migrations.CreateModel(
            name='ChecklistComplete',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                ('date', models.DateField()),
                ('points', models.IntegerField(default=0)),
                ('status', models.IntegerField(choices=[(1, 'Completed On Time'), (2, 'Completed Late'), (3, 'Not Completed'), (4, 'Informative'), (5, 'Beg Off')])),
                ('checklist', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='completes', to='checklist.checklist')),
                ('user', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to=settings.AUTH_USER_MODEL)),
            ],
            options={
                'abstract': False,
            },
        ),
        migrations.CreateModel(
            name='ChecklistSchedule',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                ('week_day', models.IntegerField(choices=[(0, 'Monday'), (1, 'Tuesday'), (2, 'Wednesday'), (3, 'Thursday'), (4, 'Friday'), (5, 'Saturday'), (6, 'Sunday')], validators=[django.core.validators.MinValueValidator(0), django.core.validators.MaxValueValidator(6)])),
                ('time_from', models.TimeField(blank=True, null=True)),
                ('time_to', models.TimeField(blank=True, null=True)),
                ('notified_day', models.DateField(blank=True, null=True)),
                ('checklist', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='schedules', to='checklist.checklist')),
            ],
            options={
                'unique_together': {('checklist', 'week_day')},
            },
        ),
        migrations.CreateModel(
            name='ChecklistAssign',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                ('type', models.IntegerField(choices=[(1, 'Executor'), (2, 'Inspector')], default=1)),
                ('checklist', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='assigns', to='checklist.checklist')),
                ('user', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to=settings.AUTH_USER_MODEL)),
            ],
            options={
                'unique_together': {('user', 'checklist', 'type')},
            },
        ),
    ]