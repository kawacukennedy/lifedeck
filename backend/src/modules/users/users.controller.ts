import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards, Request } from '@nestjs/common';
import { UsersService } from './users.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@Controller('users')
@UseGuards(JwtAuthGuard)
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get('profile')
  getProfile(@Request() req) {
    return this.usersService.findById(req.user.id);
  }

   @Patch('profile')
   updateProfile(@Request() req, @Body() updateData: any) {
     return this.usersService.update(req.user.id, updateData);
   }

   @Post('onboarding/goals')
   setGoals(@Request() req, @Body() body: { goals: any[] }) {
     return this.usersService.setGoals(req.user.id, body.goals);
   }

   @Post('onboarding/preferences')
   setPreferences(@Request() req, @Body() body: { domains: string[]; maxDailyCards: number }) {
     return this.usersService.setPreferences(req.user.id, body);
   }

   @Post('onboarding/complete')
   completeOnboarding(@Request() req) {
     return this.usersService.completeOnboarding(req.user.id);
   }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.usersService.findById(id);
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() updateData: any) {
    return this.usersService.update(id, updateData);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.usersService.delete(id);
  }
}