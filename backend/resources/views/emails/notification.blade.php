@extends('emails.layout')

@section('content')
    @if(isset($greeting))
        <div class="greeting">{{ $greeting }}</div>
    @endif

    @if(isset($message))
        <div class="message">{!! nl2br(e($message)) !!}</div>
    @endif

    @if(isset($action_url) && isset($action_text))
        <div style="text-align: center;">
            <a href="{{ $action_url }}" class="button">{{ $action_text }}</a>
        </div>
    @endif

    @if(isset($footer_message))
        <div class="message" style="margin-top: 25px; font-size: 14px;">
            {!! nl2br(e($footer_message)) !!}
        </div>
    @endif
@endsection
