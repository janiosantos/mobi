<?php

use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Schedule;

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote')->hourly();

/*
|--------------------------------------------------------------------------
| Console Routes & Scheduled Tasks
|--------------------------------------------------------------------------
*/

// Clean up expired rides
Schedule::command('mobi:cleanup-expired-rides')
    ->everyFiveMinutes()
    ->withoutOverlapping();

// Update surge pricing based on demand
Schedule::command('mobi:update-surge-pricing')
    ->everyMinute()
    ->withoutOverlapping();

// Process driver payouts
Schedule::command('mobi:process-payouts')
    ->dailyAt('02:00')
    ->timezone('America/Sao_Paulo');

// Generate daily reports
Schedule::command('mobi:generate-daily-reports')
    ->dailyAt('23:00')
    ->timezone('America/Sao_Paulo');

// Clean old notifications
Schedule::command('mobi:cleanup-notifications')
    ->weekly()
    ->mondays()
    ->at('03:00');

// Clean old ride locations (keep last 30 days)
Schedule::command('mobi:cleanup-ride-locations')
    ->weekly()
    ->sundays()
    ->at('04:00');

// Send pending driver reminders
Schedule::command('mobi:send-driver-reminders')
    ->daily()
    ->at('10:00');
