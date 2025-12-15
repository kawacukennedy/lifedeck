import { Controller, Request, Post, UseGuards, Body, Get } from '@nestjs/common';
import { AuthService } from './auth.service';
import { LocalAuthGuard } from './local-auth.guard';
import { JwtAuthGuard } from './jwt-auth.guard';

@Controller('auth')
export class AuthController {
  constructor(private authService: AuthService) {}

  @UseGuards(LocalAuthGuard)
  @Post('login')
  async login(@Request() req) {
    return this.authService.login(req.user);
  }

  @Post('register')
  async register(@Body() body: { email: string; password: string; name?: string }) {
    return this.authService.register(body.email, body.password, body.name);
  }

  @Get('google')
  @UseGuards(JwtAuthGuard)
  googleAuth() {
    // This will be handled by Passport
  }

  @Get('google/callback')
  @UseGuards(JwtAuthGuard)
  googleAuthRedirect(@Request() req) {
    return this.authService.validateOAuthLogin(req.user, 'google');
  }

  @Get('apple')
  @UseGuards(JwtAuthGuard)
  appleAuth() {
    // This will be handled by Passport
  }

  @Get('apple/callback')
  @UseGuards(JwtAuthGuard)
  appleAuthRedirect(@Request() req) {
    return this.authService.validateOAuthLogin(req.user, 'apple');
  }

  @UseGuards(JwtAuthGuard)
  @Get('profile')
  getProfile(@Request() req) {
    return req.user;
  }
}